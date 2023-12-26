# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Profiles::GeneralPolicy, type: :policy do
  subject { described_class.new(fc_user, model) }
  let(:model) { double('Profile') }

  describe 'fc user' do
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

    it { is_expected.to permit_actions(%i[edit update]) }
  end
end
