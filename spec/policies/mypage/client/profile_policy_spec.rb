# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::ProfilePolicy, type: :policy do
  subject { described_class.new(client_user, model) }
  let(:model) { double('Profile') }

  describe 'client user' do
    let(:client_user) { FactoryBot.build_stubbed(:client_user, :with_contact) }

    it { is_expected.to permit_actions(%i[show edit update]) }
  end
end
