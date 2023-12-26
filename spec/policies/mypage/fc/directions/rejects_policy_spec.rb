# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Directions::RejectsPolicy, type: :policy do
  describe 'permissions' do
    let(:model) { FactoryBot.build_stubbed(:direction, :waiting_for_fc, project:) }
    subject { described_class.new(user, model) }

    let(:user) { FactoryBot.build_stubbed(:fc_user, :activated, contact:) }
    let(:main_contact) { FactoryBot.build_stubbed(:contact, :fc, account:) }
    let(:sub_contact) { FactoryBot.build_stubbed(:contact, :fc, account:) }
    let(:account) { FactoryBot.build_stubbed(:account_fc) }
    let(:project) { FactoryBot.build_stubbed(:project, fc_account: account, main_fc_contact: main_contact, sub_fc_contact: sub_contact) }

    context 'not main and sub fc' do
      let(:contact) { FactoryBot.build_stubbed(:contact, :fc) }

      it { is_expected.to forbid_actions(%i[show create]) }
    end

    context 'main fc' do
      let(:contact) { main_contact }

      it { is_expected.to permit_actions(%i[show create]) }
    end

    context 'sub fc' do
      let(:contact) { sub_contact }

      it { is_expected.to permit_actions(%i[show create]) }
    end
  end
end
