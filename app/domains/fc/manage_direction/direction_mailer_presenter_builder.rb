# frozen_string_literal: true

module Fc::ManageDirection
  class DirectionMailerPresenterBuilder
    include ::ManageDirection::DirectionMailerPresenterBuilder

    def initialize(direction)
      @direction = direction
    end

    def build
      DirectionMailerPresenter.new(
        direction:       direction.decorate,
        main_fc_contact: ProfileDecorator.decorate(main_fc_contact),
        sub_fc_contact:  ProfileDecorator.decorate(sub_fc_contact),
        fc_account:      ProfileDecorator.decorate(fc_account),
        main_mws_user:,
        sub_mws_user:
      )
    end

    private

    # :nocov:
    def sf_contacts
      @sf_contacts ||= begin
        project = direction.project
        contact_ids = [project.main_fc_contact&.sfid, project.sub_fc_contact&.sfid].compact
        Salesforce::Contact.find_multi(contact_ids, CONTACT_FIELDS)
      end
    end
    # :nocov:

    def main_fc_contact
      sf_contacts.find { |contact| contact.Id == direction.project.main_fc_contact.sfid } || Salesforce::Contact.null
    end

    def sub_fc_contact
      sub_fc_contact = direction.project.sub_fc_contact
      (sub_fc_contact.presence && sf_contacts.find { |contact| contact.Id == sub_fc_contact.sfid }) || Salesforce::Contact.null
    end
  end
end
