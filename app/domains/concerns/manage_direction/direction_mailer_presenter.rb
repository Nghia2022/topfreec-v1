# frozen_string_literal: true

module ManageDirection
  module DirectionMailerPresenter
    extend ActiveSupport::Concern

    def email_from
      sub_mws_user.email
    end

    def email_cc_common
      [main_mws_user.email, sub_mws_user.email].compact.uniq
    end

    # :reek:UtilityFunction
    def email_bcc
      Settings.mailer.direction.bcc
    end

    def business_title
      name
    end

    def sub_mws_user_fullname
      sub_mws_user.full_name
    end
  end
end
