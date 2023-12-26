# frozen_string_literal: true

class ProjectDecorator < Draper::Decorator
  include CloudinaryHelper

  IMAGE_VERSION = 2

  delegate_all
  decorates_association :client
  delegate :client_name, to: :client

  alias_attribute :project_name, :web_projectname__c
  alias_attribute :human_resources, :web_human_resource_main__c
  alias_attribute :human_resources_sub, :web_human_resource_sub__c
  alias_attribute :job_outline, :web_joboutline__c
  alias_attribute :description, :web_projectoutline__c
  alias_attribute :background, :web_background__c
  alias_attribute :recruiting, :gyomu_tytle__c
  alias_attribute :operator_name, :owner__user_name__c
  alias_attribute :operator_comment, :web_comment__c
  alias_attribute :period, :kaishiyoteibi_input__c
  alias_attribute :account_sfid, :accountid
  alias_attribute :fc_account_sfid, :fc__c
  alias_attribute :main_fc_contact_sfid, :fc_gyomusekinin_main_new__c
  alias_attribute :sub_fc_contact_sfid, :fc_gyomusekinin_sub_new__c
  alias_attribute :compensation, :reward__c
  alias_attribute :compensation_min, :web_reward_min__c
  alias_attribute :compensation_max, :web_reward_max__c
  alias_attribute :compensation_note, :web_reward_note__c
  alias_attribute :operator_image, :web_picture__c
  alias_attribute :client_category_name, :web_clientname__c
  alias_attribute :work_section, :web_worksection__c
  alias_attribute :work_environment, :web_workenvironment__c
  alias_attribute :operating_rate_min, :web_kado_min__c
  alias_attribute :operating_rate_max, :web_kado_max__c
  alias_attribute :operating_rate_note, :web_kado_note__c
  alias_attribute :participation_period, :web_period__c
  alias_attribute :place_note, :web_place_note__c
  alias_attribute :operator_picture_flag, :web_owner_pictureflag__c
  alias_attribute :experience_categories, :experiencecatergory__c
  alias_attribute :entry_closed, :isclosedwebreception__c
  alias_attribute :period_from, :web_period_from__c
  alias_attribute :period_to, :web_period_to__c
  alias_attribute :published_at, :web_publishdatetime__c

  def experience_categories
    object.experiencecatergory__c.to_a
  end

  def meta_keywords
    experience_categories
  end

  def primary_category
    experience_categories.first
  end

  def category_slug
    (primary_category && Salesforce::PicklistValue.generate_slug(primary_category)) || 'default'
  end

  def category_image(index)
    return object.web_photo__c_transforms.categories if object.web_photo__c?

    cl_image_path("categories/#{category_slug}/#{index}.jpg", version: IMAGE_VERSION, transformation: 'categories')
  end

  def contract_type
    case object.type&.to_sym
    when :fc, :intern
      '業務委託'
    when :dispatch_contract
      '派遣契約'
    when :cn
      '正社員'
    end
  end

  def work_location
    work_prefectures__c.to_a.join(', ')
  end

  def work_options
    work_options__c.to_a.join(', ')
  end

  def operator_image_transforms
    object.web_picture__c_transforms
  end

  def jobposting_active?
    object.jobposting_isactive__c
  end

  class << self
    def collection_decorator_class
      PaginatingDecorator
    end
  end
end
