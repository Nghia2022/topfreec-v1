# frozen_string_literal: true

FactoryBot.define do
  factory :impression do
    impressionable factory: :project
    user_id { nil }
    message { nil }
    request_hash { Faker::Lorem.characters(number: 10) }
    session_hash { Faker::Lorem.characters(number: 10) }
    ip_address { Faker::Internet.ip_v4_address }
    created_at { Faker::Time.between(from: 1.day.ago, to: Time.current) }
    updated_at { created_at }
  end
end

# Impression
#   id: integer
#   impressionable_type: string
#   impressionable_id: integer
#   user_id: integer
#   controller_name: string
#   action_name: string
#   view_name: string
#   request_hash: string
#   ip_address: string
#   session_hash: string
#   message: text
#   referrer: text
#   params: text
#   created_at: datetime
#   updated_at: datetime
#   belongs_to :impressionable
