# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::ExperiencePolicy, type: :policy do
  let(:contact) { fc_user.contact }

  describe 'fc user' do
    subject { described_class.new(fc_user, model) }

    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
    let(:model) { FactoryBot.build_stubbed(:experience, contact:) }

    context 'activated' do
      it { is_expected.to permit_actions(%i[index]) }
    end

    context 'not activated yet' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it { is_expected.to forbid_actions(%i[index]) }
    end

    context 'owner' do
      it do
        is_expected.to permit_actions(%i[index])
      end
    end

    context 'not owner' do
      let(:model) { FactoryBot.build_stubbed(:experience) }

      it do
        is_expected
          .to permit_actions(%i[index])
      end
    end
  end
end
