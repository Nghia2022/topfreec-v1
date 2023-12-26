# frozen_string_literal: true

FactoryBot.define do
  factory :matching_event do
    matching { association(:matching, *matching_trait) }

    transient do
      matching_trait { [] }
    end
  end
end

# == Schema Information
#
# Table name: matching_events
#
#  id            :bigint           not null, primary key
#  new_hc_lastop :string
#  new_status    :string
#  old_hc_lastop :string
#  old_status    :string
#  root          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  matching_id   :integer
#
# Indexes
#
#  index_matching_events_on_matching_id  (matching_id)
#
