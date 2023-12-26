# frozen_string_literal: true

class Fc::Settings::ProjectRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeMethods::BeforeTypeCast
  include StartTimingAdjustable
  include AccountAttributesStorable
  extend Enumerize

  # Contact attributes
  attribute :requests, :string

  # Contact attributes
  alias_attribute :fcweb_kibou_memo__c, :requests

  validates :requests, length: { maximum: 1200 }

  def initialize(attrs = {})
    @persisted = false
    super
  end

  # :reek:TooManyStatements
  def save(contact)
    return false if invalid?

    @account = contact.account

    begin
      contact.assign_attributes(contact_attributes)

      ActiveRecord::Base.transaction do
        self.persisted = save_account! && contact.save!
      end
    ensure
      errors.merge!(account.errors)
      errors.merge!(contact.errors)
    end
  end

  def persisted?
    persisted
  end

  private

  attr_writer :persisted
  attr_reader :account

  def persisted
    @persisted ||= false
  end

  def contact_attributes
    (Contact.attribute_names & attribute_aliases.keys).index_with do |attr|
      public_send(attr)
    end
  end

  class << self
    def new_from_contact(contact)
      contact_attributes = contact.attributes.slice(*attribute_alias_keys)
      account_attributes = contact.account.attributes.slice(*attribute_alias_keys)

      new(**account_attributes, **contact_attributes).tap do |form|
        form.start_timing = form.start_timing_for_show
      end
    end

    def attribute_alias_keys
      attribute_aliases.keys
    end
  end
end
