# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::DashboardPolicy, type: :policy do
  subject { described_class.new(fc_user, nil) }

  describe 'fc user' do
    context 'valid user' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

      it { is_expected.to permit_action(:index) }
    end
  end
end
