# frozen_string_literal: true

class Fc::EditProfile::GeneralForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Dirty
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Draper::Decoratable
  extend Enumerize

  attribute :LastName, :string
  attribute :FirstName, :string
  attribute :Kana_Sei__c, :string
  attribute :Kana_Mei__c, :string
  attribute :Phone, :string
  attribute :HomePhone, :string
  attribute :MailingState, :string
  attribute :MailingCity, :string
  attribute :MailingStreet, :string
  attribute :MailingPostalCode, :string
  attribute :Email, :string

  # disable :reek:Attribute
  attr_accessor :user

  alias_attribute :last_name, :LastName
  alias_attribute :first_name, :FirstName
  alias_attribute :last_name_kana, :Kana_Sei__c
  alias_attribute :first_name_kana, :Kana_Mei__c
  alias_attribute :phone, :Phone
  alias_attribute :phone2, :HomePhone
  alias_attribute :prefecture, :MailingState
  alias_attribute :city, :MailingCity
  alias_attribute :building, :MailingStreet
  alias_attribute :zipcode, :MailingPostalCode
  alias_attribute :email, :Email

  validates :last_name, length: { maximum: 60 }
  validates :first_name, length: { maximum: 60 }
  validates :last_name_kana, length: { maximum: 255 }
  validates :first_name_kana, length: { maximum: 255 }
  validates :zipcode, presence: true, numericality: { only_integer: true }, length: { is: 7 }
  validates :phone, presence: true, numericality: { only_integer: true }, length: { in: 10..11 }
  validates :phone2, numericality: { only_integer: true }, length: { in: 10..11 }, allow_blank: true
  validates :email, length: { maximum: 80 }
  validates :prefecture, length: { maximum: 80 }
  validates :city, length: { maximum: 40 }
  validates :building, length: { maximum: 255 }

  def initialize(attrs = {}, user: nil)
    @persisted = false
    self.user = user
    super(attrs)
    clear_changes_information
  end

  def save(contact)
    return false unless valid?

    self.persisted = update_sobject(contact)
    user.send_new_otp if phone_changed?

    persisted
  end

  def serializable_hash
    attributes.tap do |attrs|
      attrs['PhoneForConfirmation__c'] = attrs.delete('Phone') if phone_changed?
    end
  end

  def persisted?
    persisted
  end

  delegate :start_year, :end_year, to: :class

  class << self
    def new_from_sobject_with_user(sobject, user: nil)
      new(sobject.slice(*attribute_names).to_h, user:)
    end

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

  private

  attr_writer :persisted

  def persisted
    @persisted ||= false
  end

  def restforce
    @restforce ||= RestforceFactory.new_client
  end

  def update_sobject(contact)
    restforce.update!(contact.sobject_name, { Id: contact.sfid }.merge(serializable_hash))
  rescue Restforce::ResponseError => e
    errors.add(:base, '何らかの問題が発生しました。後ほどお試しください')
    false
  end
end
