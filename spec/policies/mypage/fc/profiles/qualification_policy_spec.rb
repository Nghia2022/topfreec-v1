# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Profiles::QualificationPolicy, type: :policy do
  subject { described_class.new(fc_user, model) }
  let(:model) { FactoryBot.build_stubbed(:contact, :fc) }
  let(:contact) { ActiveType.cast(model, Fc::EditProfile::Qualification::Contact) }

  describe 'fc user' do
    context 'owner' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated, contact: model) }

      it do
        is_expected.to permit_actions(%i[edit update])
      end
    end

    context 'not owner' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

      it do
        is_expected.to forbid_actions(%i[edit update])
      end
    end
  end
end
