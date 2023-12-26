# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::DirectionPolicy, type: :policy do
  describe 'fc user' do
    let(:model) { FactoryBot.build_stubbed(:direction) }
    subject { described_class.new(fc_user, model) }

    context 'activated' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

      it { is_expected.to permit_actions(%i[index]) }
    end

    context 'not activated yet' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it { is_expected.to forbid_actions(%i[index]) }
    end
  end
end
