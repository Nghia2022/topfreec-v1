# frozen_string_literal: true

module Fc::Entry
  class MatchingMailerPresenter
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :matching
    attribute :project
    attribute :contact
    attribute :mws_user

    delegate :project_id, :project_name, :operator_name, to: :project

    def email_to
      contact.web_login_email
    end

    def email_cc
      [mws_user.email, Settings.mailer.matching.cc].flatten.compact
    end

    # :reek:UtilityFunction
    def email_from
      Settings.mailer.from
    end

    def fc_fullname
      contact.full_name
    end
  end
end
