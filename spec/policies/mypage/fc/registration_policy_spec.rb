# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::RegistrationPolicy, type: :policy do
  subject { described_class.new(fc_user, model) }
  let(:model) { double('Fc::MainRegistration::RegistrationForm') }

  describe 'fc user' do
    context 'not main registered yet' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated, registration_completed_at: nil) }

      it do
        is_expected.to permit_actions(%i[show create])
      end
    end

    context 'registered' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated, registration_completed_at: Time.current) }

      it do
        is_expected.to forbid_actions(%i[show create])
      end
    end
  end
end
