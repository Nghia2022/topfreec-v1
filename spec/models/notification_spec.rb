# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:receipts) }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in(:matching_remaining, :direction_workflow) }
  end

  describe '.notify_all' do
    let!(:fc_users) { FactoryBot.create_list(:fc_user, 2, :activated) }

    it do
      notification = FactoryBot.build(:notification)
      expect do
        Notification.notify_all(fc_users, notification)
        notification.receipts.reload
      end.to change(Receipt, :count).by(fc_users.size)
        .and change(notification.receipts, :count).by(fc_users.size)
    end
  end
end

# == Schema Information
#
# Table name: notifications
#
#  id                   :bigint           not null, primary key
#  body                 :text
#  draft                :boolean          default(FALSE)
#  kind                 :string
#  link                 :string(1024)
#  notification_code    :string
#  notified_object_type :string
#  sender_type          :string
#  subject              :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  notified_object_id   :bigint
#  sender_id            :bigint
#
# Indexes
#
#  index_notifications_on_kind                       (kind)
#  index_notifications_on_sender_type_and_sender_id  (sender_type,sender_id)
#  notifications_notified_object                     (notified_object_type,notified_object_id)
#
