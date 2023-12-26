# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  def i18n_subject(options = {})
    I18n.t("mailers.#{self.class.to_s.underscore}.#{action_name}.subject", **options)
  end
end
