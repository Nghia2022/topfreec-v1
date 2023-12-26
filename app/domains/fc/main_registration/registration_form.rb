# frozen_string_literal: true

# :reek:MissingSafeMethod { exclude: [ trim_work_categories!, arrange_work_categories!] }
class Fc::MainRegistration::RegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  include ActiveRecord::AttributeMethods::BeforeTypeCast
  include StartTimingAdjustable
  include AccountAttributesStorable
  extend Enumerize

  attribute :prefecture, :string
  attribute :city, :string
  attribute :building, :string
  attribute :zipcode, :string

  # TODO: #3353 :experienced_works, :desired_worksの削除
  #       config/locales/models/registration.ja.yml の修正
  attribute :requests, :string
  attribute :experienced_works, array: :string
  attribute :experienced_works_main, array: :string
  attribute :experienced_works_sub, array: :string
  attribute :desired_works, array: :string
  attribute :desired_works_main, array: :string
  attribute :desired_works_sub, array: :string
  attribute :company_sizes, array: :string
  attribute :work_location1, :string
  attribute :work_location2, :string
  attribute :work_location3, :string
  attribute :business_form, array: :string

  # Contact attributes
  alias_attribute :fcweb_kibou_memo__c, :requests
  alias_attribute :experienced_works__c, :experienced_works
  alias_attribute :experienced_works_main__c, :experienced_works_main
  alias_attribute :experienced_works_sub__c, :experienced_works_sub
  alias_attribute :desired_works__c, :desired_works
  alias_attribute :desired_works_main__c, :desired_works_main
  alias_attribute :desired_works_sub__c, :desired_works_sub
  alias_attribute :experienced_company_size__c, :company_sizes
  alias_attribute :work_prefecture1__c, :work_location1
  alias_attribute :work_prefecture2__c, :work_location2
  alias_attribute :work_prefecture3__c, :work_location3
  alias_attribute :work_options__c, :business_form

  NO_PARTICIPATE_COMPANY_NAMES_MAXIMUM = 1200

  validates :zipcode, presence: true, numericality: { only_integer: true }, length: { is: 7 }
  validates :prefecture, presence: true
  validates :city, presence: true

  validates :work_location1, presence: true
  validates :work_location2, absence: { if: -> { work_location1.blank? } }
  validates :work_location3, absence: { if: -> { work_location2.blank? } }
  validates :requests, length: { maximum: 1200 }
  # TODO: #3353 if: の削除
  validates :experienced_works_sub,
            length:    { maximum: 100 },
            inclusion: {
              in: ->(_) { WorkCategory.pluck(:sub_category).flatten }
            },
            if:        :new_work_category?
  validates :desired_works_sub,
            length:    { maximum: 100 },
            inclusion: {
              in: ->(_) { WorkCategory.pluck(:sub_category).flatten }
            },
            if:        :new_work_category?

  def initialize(attrs = {})
    @persisted = false
    super
  end

  def save(fc_user)
    arrange_work_categories!
    return false if invalid?

    persist(fc_user)
  end

  def persisted?
    persisted
  end

  def restore(contact)
    return unless contact

    restore_from_profile(contact)
    restore_from_contact(contact)
    restore_from_account(contact&.account)
  end

  private

  attr_writer :persisted
  attr_reader :account

  def persisted
    @persisted ||= false
  end

  def persist(fc_user)
    contact = fc_user.person

    ActiveRecord::Base.transaction do
      store_desired_condition(contact)
      fc_user.update(registration_completed_at: Time.current)
      self.persisted = store_profile(contact)
    end
  end

  def store_profile(contact)
    profile = Fc::MainRegistration::Profile.new
    profile.assign_attributes(attributes.slice(*profile.attribute_aliases.keys))
    profile.save(contact)
  end

  def store_desired_condition(contact)
    @account = contact.account

    contact.assign_attributes(contact_attributes)

    save_account! && contact.save!
  end

  def restore_from_profile(contact)
    profile = Fc::MainRegistration::Profile.new_from_sobject(contact.to_sobject)
    assign_attributes(profile.aliase_attributes)
  end

  def restore_from_account(account)
    return unless account

    attrs = account_attribute_keys.index_with do |attr|
      account.public_send(attr)
    end
    assign_attributes(attrs)
  end

  def restore_from_contact(contact)
    attrs = contact_attribute_keys.index_with do |attr|
      contact.public_send(attr)
    end
    assign_attributes(attrs)
  end

  def contact_attribute_keys
    Contact.attribute_names & attribute_aliases.keys
  end

  def contact_attributes
    contact_attribute_keys.index_with do |attr|
      public_send(attr)
    end
  end

  # TODO: #3353 削除
  def new_work_category?
    Flipper.enabled? :new_work_category
  end

  def trim_work_categories!
    experienced_works_sub&.reject!(&:blank?)
    desired_works_sub&.reject!(&:blank?)
  end

  def arrange_work_categories!
    trim_work_categories!
    assign_attributes(works_main_attributes)
  end

  def works_main_attributes
    {
      experienced_works_main: WorkCategory.group_sub_categories(experienced_works_sub).keys,
      desired_works_main:     WorkCategory.group_sub_categories(desired_works_sub).keys
    }
  end

  class << self
    # :nocov:
    def start_year
      1930
    end
    # :nocov:

    # :nocov:
    def end_year
      Time.current.year
    end
    # :nocov:
  end

  delegate :start_year, :end_year, to: :class
end
