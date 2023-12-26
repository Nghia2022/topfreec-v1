# frozen_string_literal: true

class Fc::EditProfile::QualificationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Draper::Decoratable

  attribute :license, :string

  alias_attribute :license__c, :license

  validates :license, length: { maximum: 500 }

  def initialize(attrs = {})
    @persisted = false
    super
  end

  def save(contact)
    if valid?
      contact.assign_attributes(serializable_hash)
      self.persisted = contact.save
    else
      false
    end
  end

  def serializable_hash
    attribute_aliases.keys.index_with { |attr| send(attr) }
  end

  def persisted?
    persisted
  end

  private

  attr_writer :persisted

  def persisted
    @persisted ||= false
  end

  class << self
    def new_from_contact(contact)
      new(contact.slice(*attribute_aliases.keys).to_h)
    end
  end
end
