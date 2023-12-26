# frozen_string_literal: true

module ContactEmailUpdatable
  extend ActiveSupport::Concern

  class_methods do
    def confirm_by_token(confirmation_token)
      transaction do
        super
      end
    end
  end

  def after_confirmation
    update_contact_email_in_salesforce
  end

  def update_contact_email_in_salesforce
    restforce.update!('Contact', Id: contact_sfid, Web_LoginEmail__c: email)
  end
end
