# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  subject { described_class.new(user, model) }
  let(:model) { nil }

  shared_examples 'forbid all actions' do
    it do
      is_expected.to forbid_actions(%i[index show new create edit update destroy])
    end
  end

  context 'visitor' do
    let(:user) { nil }

    it_behaves_like 'forbid all actions'
  end

  context 'FC' do
    let(:user) { FactoryBot.build_stubbed(:fc_user, :activated) }

    it_behaves_like 'forbid all actions'
  end

  context 'FC Company' do
    let(:user) { FactoryBot.build_stubbed(:fc_user, :fc_company) }

    it_behaves_like 'forbid all actions'
  end

  context 'Client' do
    let(:user) { FactoryBot.build_stubbed(:client_user) }

    it_behaves_like 'forbid all actions'
  end

  describe 'Scope' do
    subject { described_class::Scope.new(user, model) }
    let(:user) { nil }

    it do
      is_expected.to respond_to(:resolve)
    end
  end
end
