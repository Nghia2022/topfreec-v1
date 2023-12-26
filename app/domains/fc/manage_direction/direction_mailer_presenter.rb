# frozen_string_literal: true

module Fc::ManageDirection
  class DirectionMailerPresenter
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ApplicationHelper
    include ::ManageDirection::DirectionMailerPresenter

    attribute :direction
    attribute :main_fc_contact
    attribute :sub_fc_contact
    attribute :fc_account
    attribute :main_mws_user
    attribute :sub_mws_user
    attribute :modification_requester_of_fc_full_name

    delegate :client_name, :project, :approver_of_fc, :name, to: :direction

    def email_to
      main_fc_contact.web_login_email
    end

    def email_cc
      [sub_fc_contact?.presence && sub_fc_contact.web_login_email, email_cc_common].flatten.compact
    end

    def main_fc_contact_fullname
      main_fc_contact.full_name
    end

    def sub_fc_contact_fullname
      sub_fc_contact.full_name
    end

    def fc_fullname
      fc_account.full_name
    end

    def sub_mws_user_fullname
      sub_mws_user.full_name
    end

    def auto_approve_schedule_fc
      I18n.ln(direction.auto_approve_schedule_fc, format: :long) || 'YYYY年MM月DD日'
    end

    def approved_date_by_cl
      I18n.ln(direction.approved_date_by_cl, format: :localized_datetime) || 'YYYY年mm月dd日 %HH時%MM分'
    end

    def approved_date_by_fc
      I18n.ln(direction.approved_date_by_fc, format: :localized_datetime) || 'YYYY年mm月dd日 %HH時%MM分'
    end

    # :nocov:
    def modification_requested_at
      I18n.ln(direction.updated_at, format: :localized_datetime)
    end
    # :nocov:

    def direction_detail
      text_format direction.direction_detail
    end

    def comment_from_fc
      text_format direction.comment_from_fc
    end

    def sub_fc_contact?
      sub_fc_contact.present? && main_fc_contact != sub_fc_contact
    end
  end
end
