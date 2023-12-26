# frozen_string_literal: true

class Fc::EditProfile::PhoneConfirmationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include SalesforceHelpers

  attribute :code

  def initialize(attr = {}, user: nil)
    self.user = user
    super(attr)
  end

  def save
    return unless user.authenticate_otp(code)

    update_phone_in_salesforce

    true
  end

  private

  attr_accessor :user

  def update_phone_in_salesforce
    contact = user.contact.to_sobject
    restforce.update!('Contact', Id: user.contact_sfid, Phone: contact.PhoneForConfirmation__c, PhoneForConfirmation__c: nil)
  end
end
