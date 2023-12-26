# frozen_string_literal: true

# disable :reek:TooManyMethods
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include NotificationReceivable
  include OauthAuthenticatable
  include CacheSupport
  include Theming

  devise_group :user, contains: %i[fc_user client_user wp_user]

  # :nocov:
  if ENV.key?('BASIC_AUTH_USERNAME') && ENV.key?('BASIC_AUTH_PASSWORD')
    http_basic_authenticate_with(name:     ENV.fetch('BASIC_AUTH_USERNAME', nil),
                                 password: ENV.fetch('BASIC_AUTH_PASSWORD', nil),
                                 if:       :require_basic_auth?)
  end
  # :nocov:

  before_action :reload_rails_admin, if: :rails_admin_path?
  before_action :set_view_handler
  before_action :force_trailing_slash

  attr_reader :rendered_template

  def decorated_fc_user
    @decorated_fc_user ||= current_fc_user&.decorate
  end
  helper_method :decorated_fc_user

  def current_fc_profile
    return nil if current_fc_account.blank?

    @current_fc_profile ||=
      ProfileDecorator.decorate(
        cache_sobject(current_fc_user.account_cache_key_with_version, expires_in: 1.hour) do
          current_fc_account.to_sobject
        end
      )
  end
  helper_method :current_fc_profile

  protected

  def page_param
    params.fetch(:page, 1)
  end

  def per_page_param
    params.fetch(:per_page, 25)
  end

  def permitted_attributes(record, action = action_name, policy_class: nil)
    policy = policy_class ? policy_class.new(pundit_user, record) : policy(record)
    method_name = if policy.respond_to?("permitted_attributes_for_#{action}")
                    "permitted_attributes_for_#{action}"
                  else
                    'permitted_attributes'
                  end
    pundit_params_for(record).permit(*policy.public_send(method_name))
  end

  private

  alias pundit_user current_user

  def force_trailing_slash
    uri = URI.parse(request.original_url)

    return unless params[:trailing_slash] && !uri.path.ends_with?('/') && request.get?

    uri.path += '/'
    redirect_to uri.to_s, status: :moved_permanently
  end

  # :nocov:
  def reload_rails_admin
    ApplicationRecord.descendants.map(&:model_name).map do |model|
      RailsAdmin::Config.reset_model(model.name)
    end
    RailsAdmin::Config::Actions.reset

    load(Rails.root.join('config', 'initializers', 'rails_admin.rb'))
  end
  # :nocov:

  def rails_admin_path?
    Rails.env.development? && controller_path == 'rails_admin/main'
  end

  def set_view_handler
    view_handler = if params[:view_handler] == 'reset'
                     # :nocov:
                     session.delete(:view_handler)
                     :erb
                     # :nocov:
                   else
                     session[:view_handler] = params.fetch(:view_handler) { session.fetch(:view_handler, :erb) }.to_sym
                   end

    lookup_context.handlers.then { |handlers| handlers.unshift handlers.delete(view_handler) }
  end

  def current_fc_account
    @current_fc_account ||= current_fc_user&.account
  end

  # disable :reek:TooManyStatements
  def _render_template(options)
    @rendered_template = options[:template]

    apply_theme(options)
    build_meta(options) if respond_to? :build_meta, true
    build_breadcrumbs(options) if respond_to? :build_breadcrumbs, true

    super
  end

  # :reek:TooManyStatements
  def apply_theme(options)
    return unless rendered_template

    lookup_context.variants = options[:variant]
    template = begin
      lookup_context.find_template(rendered_template, options[:prefixes], false)
    rescue StandardError
      nil
    end

    return if template&.variant.present?

    options.delete(:variant)
    lookup_context.variants = nil
  end

  def header_options
    @header_options ||= { receipts: }
  end
  helper_method :header_options

  concerning :Meta do
    protected

    def meta_scope
      [:meta, controller_path, action_name].join('.')
    end

    def default_meta
      I18n.t('meta.default')
    end

    def page_meta
      I18n.t(meta_scope, default: {})
    end

    def build_meta(_options)
      set_meta_tags title:       page_meta[:title],
                    site:        page_meta.fetch(:site, default_meta[:site]),
                    reverse:     page_meta.fetch(:reverse, true),
                    separator:   '|',
                    description: page_meta[:description],
                    keywords:    page_meta[:keywords]
    end

    def build_ogp(options = {})
      scheme = request.scheme
      host_with_port = request.host_with_port
      fullpath = request.fullpath

      set_meta_tags og: {
        type:        options.fetch(:type, 'website'),
        site_name:   default_meta[:site],
        title:       :title,
        url:         "#{scheme}://#{host_with_port}#{fullpath}",
        description: :description,
        image:       "#{scheme}://#{host_with_port}/assets/images/ogp.png"
      }
    end

    def build_twitter_card(_options = {})
      set_meta_tags twitter: {
        card:        'summary_large_image',
        site:        default_meta[:site],
        title:       :title,
        description: :description
      }
    end

    # :nocov:
    def require_basic_auth?
      request.path !~ %r{\A/oauth/}
    end
    # :nocov:
  end
end
