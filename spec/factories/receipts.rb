# frozen_string_literal: true

FactoryBot.define do
  factory :receipt do
    transient do
      notification_trait { [] }
    end

    trait :with_notification do
      notification { FactoryBot.build(:notification, *notification_trait) }
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
