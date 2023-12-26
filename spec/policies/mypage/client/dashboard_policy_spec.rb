# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::DashboardPolicy, type: :policy do
  subject { described_class.new(client_user, nil) }

  describe 'client user' do
    context 'valid user' do
      let(:client_user) { FactoryBot.build_stubbed(:client_user, :with_contact) }

      it { is_expected.to permit_action(:index) }
    end
  end
end
