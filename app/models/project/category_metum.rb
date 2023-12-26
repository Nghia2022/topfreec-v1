# frozen_string_literal: true

class Project::CategoryMetum < ActiveYaml::Base
  set_root_path Rails.root.join('db/fixtures')
  set_filename 'project/category_meta'

  I18N_SCOPE = 'activemodel.defaults.project/category_metum'

  field :meta_title
  field :meta_description
  field :meta_keywords

  alias title meta_title
  alias description meta_description
  alias keywords meta_keywords

  class Null < Project::CategoryMetum
    field :meta_title, default: I18n.t(:meta_title, scope: I18N_SCOPE)
    field :meta_description, default: I18n.t(:meta_description, scope: I18N_SCOPE)
    field :meta_keywords, default: I18n.t(:meta_keywords, scope: I18N_SCOPE)
  end

  class << self
    # :nocov:
    def to_enum
      all.pluck(:id)
    end
    # :nocov:

    # :nocov:
    def options
      all.pluck(:title, :id)
    end
    # :nocov:

    def find_or_null(category)
      find_by(title: category) || Null.new
    end
  end
end
