# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SalesforceHelpers, type: :model do
  describe '#cache_key_with_version' do
    subject { model.cache_key_with_version }

    context 'model has a systemmodstamp in attributes' do
      let(:model) { FactoryBot.build_stubbed(:account_fc, systemmodstamp: '2020/10/07'.in_time_zone) }

      it 'should return cache key with systemmodstamp' do
        is_expected.to eq "account/fcs/#{model.id}-20201006150000000000"
      end

      context 'if systemmodstamp is blanked' do
        before do
          model.systemmodstamp = nil
        end

        it 'should return cache key without systemmodstamp' do
          is_expected.to eq "account/fcs/#{model.id}"
        end
      end
    end

    context 'model does not have a systemmodstamp in attributes' do
      let(:model) { FactoryBot.build_stubbed(:fc_user, updated_at: '2020/10/07'.in_time_zone) }

      it 'fallback to superclass' do
        is_expected.to eq "fc_users/#{model.id}-20201006150000000000"
      end
    end
  end
end
