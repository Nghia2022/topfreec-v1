# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::HistoryPolicy, type: :policy do
  subject { described_class.new(fc_user, model) }
  let(:model) { double('History') }

  describe 'fc user' do
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

    it { is_expected.to permit_actions(%i[index]) }
  end
end
