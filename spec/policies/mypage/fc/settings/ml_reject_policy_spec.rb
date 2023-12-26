# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Settings::MlRejectPolicy, type: :policy do
  describe 'edit ml reject' do
    subject { described_class.new(fc_user, model) }

    let(:model) { contact }
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

    context 'not owner' do
      let!(:contact) { FactoryBot.build_stubbed(:contact, :fc) }

      it { is_expected.to forbid_actions(%i[index edit update destroy]) }
    end

    context 'owner' do
      let(:contact) { fc_user.contact }

      it { is_expected.to permit_actions(%i[index edit update destroy]) }
    end
  end
end
