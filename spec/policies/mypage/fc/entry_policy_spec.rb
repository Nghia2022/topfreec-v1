# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::EntryPolicy, type: :policy do
  subject { described_class.new(fc_user, model) }
  let(:model) { FactoryBot.build_stubbed(:matching) }

  describe 'fc user' do
    context 'activated' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

      it { is_expected.to permit_actions(%i[index]) }
    end

    context 'not activated yet' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it { is_expected.to forbid_actions(%i[index]) }
    end
  end

  describe '.scope' do
    subject { described_class.const_get(:Scope).new(fc_user, model).resolve }

    let(:model) { fc_user.account.matchings }
    let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }
    let!(:visible_entries) { FactoryBot.create_list(:matching, 5, :with_project, account: fc_user.account, root__c: :self_recommend_fcweb, project_trait:) }
    let!(:invisible_entries) { FactoryBot.create_list(:matching, 5, :with_project, account: fc_user.account, root__c: :recommend_sales, project_trait:) }
    let(:project_trait) { [:with_publish_datetime] }

    it { is_expected.to match_array(visible_entries) }
    it { is_expected.not_to include(*invisible_entries) }
  end
end
