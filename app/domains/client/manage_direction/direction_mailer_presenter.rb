# frozen_string_literal: true

module Client::ManageDirection
  class DirectionMailerPresenter
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ApplicationHelper
    include ::ManageDirection::DirectionMailerPresenter

    attribute :direction
    attribute :main_cl_contact
    attribute :sub_cl_contact
    attribute :fc_account
    attribute :main_mws_user
    attribute :sub_mws_user
    attribute :authorizer_of_client_full_name

    delegate :client_name, :auto_approve_schedule_cl, :approver_of_cl, :name, :project, to: :direction

    def email_to
      main_cl_contact.web_login_email
    end

    def email_cc
      [sub_cl_contact?.presence && sub_cl_contact.web_login_email, email_cc_common].flatten.compact
    end

    def main_cl_contact_fullname
      main_cl_contact.full_name
    end

    def sub_cl_contact_fullname
      sub_cl_contact.full_name
    end

    def fc_fullname
      fc_account.full_name
    end

    def new_direction_detail
      text_format direction.new_direction_detail
    end

    def request_datetime
      I18n.ln(direction.request_datetime, format: :localized_datetime)
    end

    def auto_approve_schedule_cl
      I18n.ln(direction.auto_approve_schedule_cl, format: :long) || 'YYYY年MM月DD日'
    end

    def approved_date_by_cl
      I18n.ln(direction.approved_date_by_cl, format: :localized_datetime) || 'YYYY年mm月dd日 %HH時%MM分'
    end

    def direction_detail
      text_format direction.direction_detail
    end

    def sub_cl_contact?
      sub_cl_contact.present? && main_cl_contact != sub_cl_contact
    end
  end
end
