# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectPolicy, type: :policy do
  subject { described_class.new(fc_user, model) }

  describe 'visitor' do
    let(:fc_user) { nil }
    let(:model) { FactoryBot.build_stubbed(:project) }

    it { is_expected.to permit_actions(%i[index show]) }

    context 'unpublished project' do
      let(:model) { FactoryBot.build_stubbed(:project) }

      before do
        allow(model).to receive(:published?).and_return(false)
      end

      it { is_expected.to forbid_action(:show) }
    end
  end
end
