# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::ReceiptPolicy, type: :policy do
  let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
  let(:someone) { FactoryBot.build_stubbed(:fc_user) }

  describe '#update?' do
    subject { described_class.new(fc_user, model) }

    context 'receiver' do
      let(:model) { FactoryBot.build_stubbed(:receipt, :with_notification, receiver: fc_user) }

      it { is_expected.to permit_actions(%i[update]) }
    end

    context 'not receiver' do
      let(:model) { FactoryBot.build_stubbed(:receipt, :with_notification, receiver: someone) }

      it { is_expected.to forbid_actions(%i[update]) }
    end
  end

  describe '.scope' do
    subject { described_class.const_get(:Scope).new(fc_user, model).resolve }

    let(:model) { Receipt }
    let!(:visible_receipts) { FactoryBot.create_list(:receipt, 5, :with_notification, receiver: fc_user) }
    let!(:invisible_receipts) { FactoryBot.create_list(:receipt, 5, :with_notification, receiver: someone) }

    it { is_expected.to match_array(visible_receipts) }
    it { is_expected.not_to include(*invisible_receipts) }
  end
end
