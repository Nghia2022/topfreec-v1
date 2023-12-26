# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::DirectionPolicy, type: :policy do
  subject { described_class.new(user, Direction) }

  describe 'permissions' do
    context 'client user' do
      let(:user) { FactoryBot.build_stubbed(:client_user, :with_contact) }

      it do
        is_expected.to permit_actions(%i[index])
      end
    end

    context 'fc user' do
      let(:user) { FactoryBot.build_stubbed(:fc_user, :activated) }

      it do
        is_expected.to forbid_actions(%i[index])
      end
    end
  end
end
