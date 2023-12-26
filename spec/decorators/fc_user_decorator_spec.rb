# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FcUserDecorator do
  subject(:decorated) { fc_user.decorate }
  let(:fc_user) { FactoryBot.create(:fc_user, :activated) }

  describe '#waiting_directions_count' do
    subject { decorated.waiting_directions_count }

    context 'when user is main_fc_contact' do
      let!(:project) { FactoryBot.create(:project, main_fc_contact: fc_user.contact) }
      let!(:direction) { FactoryBot.create(:direction, :waiting_for_fc, project:) }

      it do
        is_expected.to eq 1
      end
    end

    context 'when user is sub_fc_contact' do
      let!(:project) { FactoryBot.create(:project, main_fc_contact: fc_user.contact) }
      let!(:direction) { FactoryBot.create(:direction, :waiting_for_fc, project:) }

      it do
        is_expected.to eq 1
      end
    end

    context 'when user is just only fc_account' do
      let!(:project) { FactoryBot.create(:project, fc_account: fc_user.account) }
      let!(:direction) { FactoryBot.create(:direction, :waiting_for_fc, project:) }

      it do
        is_expected.to eq 0
      end
    end
  end

  describe '#transformed_profile_image' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, profile_image:) }

    subject { decorated.transformed_profile_image }

    context 'with profile image' do
      let(:profile_image) { 'https://example.com/' }

      it { is_expected.to eq profile_image }
    end

    context 'with no theme' do
      let(:profile_image) { nil }

      it { is_expected.to eq '/assets/images/icon/icon_login_user.svg' }
    end
  end
end
