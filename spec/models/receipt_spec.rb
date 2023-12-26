# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Receipt, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:notification) }
    it { is_expected.to belong_to(:receiver) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:mailbox).in(:inbox, :sentbox) }
  end

  describe 'scopes' do
    describe '.sentbox' do
      pending
    end

    describe '.inbox' do
      pending
    end

    describe '.is_read' do
      pending
    end

    describe '.is_unread' do
      pending
    end
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:subject).to(:notification) }
  end

  describe '#is_read?' do
    context 'when read' do
      let(:receipt) { FactoryBot.build(:receipt, read_at: Time.current) }

      it do
        expect(receipt.is_read?).to eq true
      end
    end

    context 'when not read yet' do
      let(:receipt) { FactoryBot.build(:receipt, read_at: nil) }

      it do
        expect(receipt.is_read?).to eq false
      end
    end
  end

  context 'is_unread?' do
    context 'when read' do
      let(:receipt) { FactoryBot.build(:receipt, read_at: Time.current) }

      it do
        expect(receipt.is_unread?).to eq false
      end
    end

    context 'when not read yet' do
      let(:receipt) { FactoryBot.build(:receipt, read_at: nil) }

      it do
        expect(receipt.is_unread?).to eq true
      end
    end
  end

  describe '#mark_as_read' do
    let(:receipt) { FactoryBot.build(:receipt, read_at: nil) }

    it do
      expect do
        receipt.mark_as_read
      end.to change(receipt, :is_read?).from(false).to(true)
        .and change(receipt, :is_unread?).from(true).to(false)
    end
  end

  describe '#mark_as_unread' do
    let(:receipt) { FactoryBot.build(:receipt, read_at: Time.current) }

    it do
      expect do
        receipt.mark_as_unread
      end.to change(receipt, :is_read?).from(true).to(false)
        .and change(receipt, :is_unread?).from(false).to(true)
    end
  end
end

# == Schema Information
#
# Table name: receipts
#
#  id              :bigint           not null, primary key
#  deleted_at      :datetime
#  mailbox         :string
#  read_at         :datetime
#  receiver_type   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notification_id :bigint
#  receiver_id     :bigint
#
# Indexes
#
#  index_receipts_on_mailbox                        (mailbox)
#  index_receipts_on_notification_id                (notification_id)
#  index_receipts_on_receiver_type_and_receiver_id  (receiver_type,receiver_id)
#
