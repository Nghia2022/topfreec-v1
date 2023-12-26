# frozen_string_literal: true

FactoryBot.define do
  factory :direction_event do
    direction { association(:direction, *direction_trait) }

    transient do
      direction_trait { [] }
    end

    trait :synced do
      old_hc_lastop { 'SYNCED' }
      new_hc_lastop { 'SYNCED' }
    end
  end
end

# == Schema Information
#
# Table name: direction_events
#
#  id             :bigint           not null, primary key
#  direction_sfid :string
#  mail_queued    :boolean          default(FALSE)
#  new_hc_lastop  :string
#  new_status     :string
#  old_hc_lastop  :string
#  old_status     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  direction_id   :integer
#
# Indexes
#
#  index_direction_events_on_direction_id    (direction_id)
#  index_direction_events_on_direction_sfid  (direction_sfid)
#
