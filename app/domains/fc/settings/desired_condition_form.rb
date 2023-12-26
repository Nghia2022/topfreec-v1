# frozen_string_literal: true

class Fc::Settings::DesiredConditionForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeMethods::BeforeTypeCast
  extend Enumerize
  extend Fc::Settings::ContactAttributable

  # TODO: #3353 不要なattributesの削除
  # Contact attributes
  attribute :experienced_works, array: :string
  attribute :desired_works, array: :string
  attribute :company_sizes, array: :string
  attribute :work_location1, :string
  attribute :work_location2, :string
  attribute :work_location3, :string
  attribute :business_form, array: :string

  # Contact attributes
  alias_attribute :experienced_works__c, :experienced_works
  alias_attribute :desired_works__c, :desired_works
  alias_attribute :experienced_company_size__c, :company_sizes
  alias_attribute :work_prefecture1__c, :work_location1
  alias_attribute :work_prefecture2__c, :work_location2
  alias_attribute :work_prefecture3__c, :work_location3
  alias_attribute :work_options__c, :business_form

  ARRAY_ATTRIBUTES = %w[
    experienced_works__c
    desired_works__c
    experienced_company_size__c
    work_options__c
  ].freeze

  validates :work_location1, presence: true
  validates :work_location2, absence: { if: -> { work_location1.blank? } }
  validates :work_location3, absence: { if: -> { work_location2.blank? } }

  def initialize(attrs = {})
    @persisted = false
    super
  end

  def save(contact)
    return false if invalid?

    begin
      contact.assign_attributes(contact_attributes)

      ActiveRecord::Base.transaction do
        self.persisted = contact.save!
      end
    ensure
      errors.merge!(contact.errors)
    end
  end

  def persisted?
    persisted
  end

  private

  attr_writer :persisted

  def persisted
    @persisted ||= false
  end

  def contact_attributes
    (Contact.attribute_names & attribute_aliases.keys).index_with do |attr|
      value = public_send(attr)
      ARRAY_ATTRIBUTES.include?(attr) ? value.to_a.compact_blank : value
    end
  end
end
