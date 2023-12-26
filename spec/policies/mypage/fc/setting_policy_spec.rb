# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::SettingPolicy, type: :policy do
  subject { described_class.new(fc_user, model) }
  let(:model) { double('Setting') }

  describe 'fc user' do
    shared_examples 'permissions' do
      it do
        is_expected.to permit_actions(%i[index])
      end
    end

    context 'when user is fc' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

      it_behaves_like 'permissions'
    end

    context 'when user is fc company' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :fc_company) }

      it_behaves_like 'permissions'
    end
  end
end
