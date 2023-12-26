# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraphs(number: rand(3..7)).join("\n") }
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
