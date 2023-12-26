# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client::ManageDirection::Direction, type: :model do
  describe 'validations' do
    subject { ActiveType.cast(model, described_class) }

    context 'rejected' do
      let(:model) { FactoryBot.build_stubbed(:direction, :rejected_by_client) }

      it do
        is_expected.to validate_presence_of(:new_direction_detail)
      end
    end

    context 'not rejected' do
      let(:model) { FactoryBot.build_stubbed(:direction) }

      it do
        is_expected.not_to validate_presence_of(:new_direction_detail)
      end
    end
  end
end
