# frozen_string_literal: true

class ProjectsController < ApplicationController
  include ProjectSearchable

  layout 'projects/application'

  before_action :set_body_class
  before_action :authorize_resources, only: %i[index]
  before_action :authorize_resource, only: %i[show]
  before_action :redirect_to_projects_path, only: %i[index]

  include TrackFieldsUpdatable
  skip_after_action :update_tracked_fields, except: %i[show]

  def index
    add_breadcrumb 'TOP', :root_path
    add_index_breadcrumb
  end

  def show
    add_breadcrumb 'TOP', :root_path
    add_breadcrumb '案件検索結果一覧', :projects_path
    add_breadcrumb '案件詳細'
    impressionist(project, current_user&.class_name, unique: [:session_hash])
  end

  def featured
    add_breadcrumb 'TOP', :root_path
    add_breadcrumb '注目案件一覧', :featured_projects_path
  end

  private

  def set_body_class
    @body_class = :projects
  end

  def related_projects
    @related_projects ||= begin
      other_projects = policy_scope(Project).where.not(sfid: project.sfid)
      Projects::RelatedProjectsQuery.call(relation: other_projects, project:, display_limit: 10).within_half_year.limit(10).decorate
    end
  end

  def project_category_metum
    @project_category_metum ||= ProjectCategoryMetum.find_by(slug: params[:slug])
  end

  def projects
    project_category_metum.present? ? projects_from(project_category_metum.projects) : projects_from(Project)
  end

  def featured_projects
    projects_from(Project.featured_order)
  end

  def projects_from(scope)
    @projects_from ||= ProjectSearchQuery.call(relation: scope, form: search_form, user: current_user).then do |projects|
      policy_scope(projects).page(page_param).decorate
    end
  end

  def project
    @project ||= policy_scope(Project.published, policy_scope_class: ProjectPolicy::Scope).find_by!(project_id: params[:id]).decorate
  end

  def entry_exists?
    return false unless fc_user_signed_in?

    project.entry_exists?(current_fc_user)
  end

  def entry_stopped?
    return false unless fc_user_signed_in?

    project.entry_stopped?(current_fc_user)
  end

  def authorize_resources
    authorize projects, policy_class: ProjectPolicy
  end

  def authorize_resource
    authorize project, policy_class: ProjectPolicy
  end

  # TODO: #3440 削除する
  def redirect_to_projects_path
    redirect_to projects_path if !FeatureSwitch.enabled?(:new_project_category_meta) && params[:slug].present?
  end

  def add_index_breadcrumb
    if project_category_metum.present?
      add_breadcrumb "#{project_category_metum.category_name}案件検索結果一覧", slug_projects_path(project_category_metum.slug)
    else
      add_breadcrumb '案件検索結果一覧', :projects_path
    end
  end

  helper_method :projects, :project_category_metum, :featured_projects, :project, :related_projects, :search_params, :entry_exists?, :entry_stopped?

  concerning :Meta do
    protected

    def build_meta(options)
      super
      send("build_meta_for_#{options[:template]}")
    end

    # rubocop:disable Metrics/AbcSize
    def build_meta_for_index
      category = search_form.category_metum

      set_meta_tags title:       search_form.meta_title,
                    description: category.description,
                    keywords:    category.keywords,
                    site:        page_meta.fetch(:site, default_meta[:site]),
                    reverse:     page_meta.fetch(:reverse, true),
                    separator:   '|',
                    canonical:   (slug_projects_url(category.slug) if search_form.canonical?)
    end
    # rubocop:enable Metrics/AbcSize

    def build_meta_for_show
      set_meta_tags title:       project.project_name,
                    site:        page_meta.fetch(:site, default_meta[:site]),
                    reverse:     page_meta.fetch(:reverse, true),
                    separator:   '|',
                    description: project.description,
                    keywords:    project.meta_keywords
      build_ogp(type: 'article')
      build_twitter_card
    end

    def build_meta_for_featured
      set_meta_tags title:       '注目案件一覧',
                    description: '',
                    keywords:    '',
                    site:        page_meta.fetch(:site, default_meta[:site]),
                    reverse:     page_meta.fetch(:reverse, true),
                    separator:   '|'
    end
  end
end
