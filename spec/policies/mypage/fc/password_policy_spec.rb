# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::PasswordPolicy, type: :policy do
  subject { described_class.new(user, model) }
  let(:model) { user }

  describe 'fc user' do
    shared_examples 'permissions' do
      it do
        is_expected.to permit_actions(%i[edit update])
      end

      it do
        is_expected.to permit_mass_assignment_of(%i[current_password password password_confirmation]).for_action(:update)
      end

      it do
        is_expected.to forbid_mass_assignment_of(%i[email]).for_action(:update)
      end
    end

    context 'when user is fc' do
      let(:user) { FactoryBot.build_stubbed(:fc_user, :activated) }

      it_behaves_like 'permissions'
    end

    context 'when user is fc company' do
      let(:user) { FactoryBot.build_stubbed(:fc_user, :fc_company) }

      it_behaves_like 'permissions'
    end
  end
end
