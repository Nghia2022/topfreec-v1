# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::ManageDirection::Direction, type: :model do
  describe 'validations' do
    subject { ActiveType.cast(model, described_class) }

    context 'rejected' do
      let(:model) { FactoryBot.build_stubbed(:direction, :rejected_by_fc) }

      it do
        is_expected.to validate_presence_of(:comment_from_fc)
      end
    end

    context 'not rejected' do
      let(:model) { FactoryBot.build_stubbed(:direction) }

      it do
        is_expected.not_to validate_presence_of(:comment_from_fc)
      end
    end
  end

  describe 'filter_by_status' do
    let(:project) { FactoryBot.build_stubbed(:project, :with_client) }
    let!(:waiting_for_fc) { ActiveType.cast(FactoryBot.create(:direction, :waiting_for_fc, project:), described_class) }
    let!(:completed) { ActiveType.cast(FactoryBot.create(:direction, :completed, project:), described_class) }
    let!(:rejected_by_fc) { ActiveType.cast(FactoryBot.create(:direction, :rejected_by_fc, project:), described_class) }

    subject { described_class.filter_by_status(status) }

    context 'waiting' do
      let(:status) { 'waiting_for_fc' }

      it { is_expected.to eq [waiting_for_fc] }
    end

    context 'replied' do
      let(:status) { 'completed' }

      it { is_expected.to eq [completed] }
    end

    context 'pending' do
      let(:status) { 'rejected' }

      it { is_expected.to eq [rejected_by_fc] }
    end

    context 'none' do
      let(:status) { '' }

      it { is_expected.to eq [waiting_for_fc, completed, rejected_by_fc] }
    end
  end
end
