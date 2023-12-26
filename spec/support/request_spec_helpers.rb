# frozen_string_literal: true

# https://github.com/plataformatec/devise/wiki/How-To:-sign-in-and-out-a-user-in-Request-type-specs-(specs-tagged-with-type:-:request)
module RequestSpecHelpers
  include Warden::Test::Helpers

  def self.included(base)
    base.before(:each) { Warden.test_mode! }
    base.after(:each) { Warden.test_reset! }
  end

  def sign_in(resource)
    disable_send_otp if resource.is_a? FcUser
    login_as(resource, scope: warden_scope(resource))
  end

  def sign_out(resource)
    logout(warden_scope(resource))
  end

  def disable_send_otp
    allow_any_instance_of(FcUser).to receive(:need_two_factor_authentication?).and_return(false)
  end

  def response_json
    JSON.parse(response.body)
  end

  # :reek:NestedIterators, :reek:UtilityFunction
  def inject_session(hash)
    Warden.on_next_request do |proxy|
      hash.each do |key, value|
        proxy.raw_session[key] = value
      end
    end
  end

  private

  def warden_scope(resource)
    if resource.is_a?(Wordpress::WpUser)
      :wp_user
    else
      resource.class.name.underscore.to_sym
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  %i[request controller system cell].each do |type|
    config.include RequestSpecHelpers, type:
  end
  config.include Capybara::DSL, type: :request
  config.include Capybara::RSpecMatchers, type: :request
end
