# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FcUserSmsMailer, type: :mailer do
  describe '#tow_factor' do
    subject(:mail) { described_class.two_factor(fc_user, code) }

    let(:fc_user) { instance_double(FcUser, phone_normalized: '+8109012345678') }
    let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }
    let(:code) { '123456' }

    it do
      is_expected.to deliver_to(fc_user.phone_normalized)
        .and deliver_from(Rails.application.credentials[:twilio][:phone_number])
        .and have_body_text(/#{code}/)
    end
  end
end
