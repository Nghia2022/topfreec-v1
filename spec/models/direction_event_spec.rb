# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DirectionEvent, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:direction) }
  end

  describe '#perform_request_confirmation_client?' do
    let(:direction_event) { FactoryBot.build_stubbed(:direction_event, direction_trait: [new_status], old_status:, new_status:, mail_queued:) }
    let(:mail_queued) { false }

    context 'when mail queued' do
      let(:old_status) { nil }
      let(:new_status) { :in_prepare }
      let(:mail_queued) { true }

      it do
        expect(direction_event).to be_perform_request_confirmation_to_client
      end
    end

    context 'when mail not queued' do
      let(:old_status) { nil }
      let(:new_status) { :in_prepare }
      let(:mail_queued) { false }

      it do
        expect(direction_event).not_to be_perform_request_confirmation_to_client
      end
    end

    context 'when new_status is not waiting_for_client' do
      let(:old_status) { :waiting_for_client }
      let(:new_status) { :waiting_for_fc }

      it do
        expect(direction_event).to_not be_perform_request_confirmation_to_client
      end
    end
  end

  describe '#perform_request_confirmation_to_client?' do
    let(:direction_event) { FactoryBot.build_stubbed(:direction_event, :synced, direction_trait:, old_status:, new_status:, mail_queued:) }
    let(:mail_queued) { false }

    context 'when mail queued and rejected by client' do
      let(:old_status) { nil }
      let(:new_status) { :rejected }
      let(:mail_queued) { true }
      let(:direction_trait) { [:rejected_by_client] }

      it do
        expect(direction_event).to be_perform_request_reconfirmation_to_client
      end
    end
  end

  describe '#status_changed?' do
    let(:direction_event) { FactoryBot.build_stubbed(:direction_event, old_status:, new_status:) }

    context 'changed' do
      let(:old_status) { :in_prepare }
      let(:new_status) { :waiting_for_client }

      it do
        expect(direction_event).to be_status_changed
      end
    end

    context 'not changed' do
      let(:old_status) { :in_prepare }
      let(:new_status) { :in_prepare }

      it do
        expect(direction_event).to_not be_status_changed
      end
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
