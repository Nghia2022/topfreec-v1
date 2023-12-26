# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Matching, type: :model do
  it_behaves_like 'sobject', 'Matching__c'

  describe 'associations' do
    it do
      is_expected.to belong_to(:project).with_foreign_key(:opportunity__c).with_primary_key(:sfid)
      is_expected.to belong_to(:account).with_foreign_key(:fc__c).with_primary_key(:sfid)
    end
  end

  describe 'enumerize' do
    context '#matching_status__c' do
      it do
        is_expected.to enumerize(:matching_status__c).in(
          candidate: '候補',
          win:       'WIN(マッチング)'
        ).with_default(:candidate)
      end

      context 'with invalid value' do
        let(:status) { '存在しない値' }
        let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
        let(:matching) { FactoryBot.create(:matching, :with_project, account: fc_user.account) }

        before do
          matching.update_columns(matching_status__c: status) # rubocop:disable Rails/SkipsModelValidations
          matching.reload
        end

        it do
          expect(matching.matching_status__c).to eq(status)
        end

        it do
          matching.valid?
          expect(matching.errors[:matching_status__c]).to be_present
        end
      end
    end

    context '#root__c' do
      it do
        is_expected.to enumerize(:root__c).in(
          recommend_sales:       '営業推薦',
          recommend_colabo:      'COLABO推薦',
          self_recommend_direct: '自己推薦(直連絡)',
          self_recommend_fcweb:  '自己推薦(FCWeb)'
        ).with_default(:self_recommend_fcweb)
      end
    end
  end

  describe 'aasm' do
    describe '#decline' do
      using RSpec::Parameterized::TableSyntax

      # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators, Lint/BinaryOperatorWithIdenticalOperands
      where(:status_from, :status_to, :trait, :ng_reason, :valid) do
        '候補'                           | 'FC辞退(CL挨拶前)' | :no_resume_date   | :no_ng_reason   | true
        'エントリー対象'                 | 'FC辞退(CL挨拶前)' | :no_resume_date   | :no_ng_reason   | true
        'エントリー打診済'               | 'FC辞退(CL挨拶前)' | :no_resume_date   | :no_ng_reason   | true
        'FC辞退(CL挨拶前)'               | 'FC辞退手続中'     | :no_resume_date   | :no_ng_reason   | false
        'レジュメ提出済'                 | 'FC辞退手続中'     | :no_resume_date   | :with_ng_reason | true
        'クライアント挨拶調整済'         | 'FC辞退手続中'     | :no_resume_date   | :with_ng_reason | true
        'レジュメ提出済'                 | 'FC辞退手続中'     | :no_resume_date   | :no_ng_reason   | false
        'クライアント挨拶調整済'         | 'FC辞退手続中'     | :no_resume_date   | :no_ng_reason   | false
        'FC辞退(CL挨拶後)'               | 'FC辞退手続中'     | :with_resume_date | :no_ng_reason   | false
        'オファー連絡済'                 | 'FC辞退(CL挨拶後)' | :with_resume_date | :with_ng_reason | true
        'WIN(マッチング)'                | 'FC辞退手続中'     | :with_resume_date | :no_ng_reason   | false
        'エントリー対象外'               | 'FC辞退手続中'     | :with_resume_date | :no_ng_reason   | false
        'クライアントNG(レジュメ提出後)' | 'FC辞退手続中'     | :with_resume_date | :no_ng_reason   | false
        'クライアントNG(挨拶実施後)'     | 'FC辞退手続中'     | :with_resume_date | :no_ng_reason   | false
        '候補FC辞退'                     | 'FC辞退手続中'     | :with_resume_date | :no_ng_reason   | false
        'FC辞退手続中'                   | 'FC辞退手続中'     | :with_resume_date | :no_ng_reason   | false
        '候補'                           | 'FC辞退手続中'     | :with_resume_date | :with_ng_reason | true
        '候補'                           | 'FC辞退手続中'     | :with_resume_date | :no_ng_reason   | false
      end
      # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators, Lint/BinaryOperatorWithIdenticalOperands

      with_them do
        let(:matching) { FactoryBot.build(:matching, trait, ng_reason, :with_project, :with_account, matching_status__c: status_from) }
        let(:value_hash) { Matching.matching_status__c.instance_variable_get(:@value_hash) }

        it do
          if valid
            expect(matching).to transition_from(value_hash[status_from].to_sym).to(value_hash[status_to].to_sym).on_event(:decline, {})
          else
            expect(matching).to_not allow_event(:decline, {})
          end
        end
      end
    end
  end

  describe '.for_entry_history' do
    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
    where(:root, :status, :for_entry_history) do
      '自己推薦(FCWeb)' | '候補'                                | true
      '自己推薦(FCWeb)' | 'エントリー対象'                      | true
      '自己推薦(FCWeb)' | 'エントリー打診済'                    | true
      '自己推薦(FCWeb)' | 'FC辞退(CL挨拶前)'                    | true
      '自己推薦(FCWeb)' | 'エントリー対象外'                    | true
      '自己推薦(FCWeb)' | 'レジュメ提出済'                      | true
      '自己推薦(FCWeb)' | 'クライアントNG(レジュメ提出後)'      | true
      '自己推薦(FCWeb)' | 'クライアント挨拶調整済'              | true
      '自己推薦(FCWeb)' | 'FC辞退手続中'                        | true
      '自己推薦(FCWeb)' | 'FC辞退(CL挨拶後)'                    | true
      '自己推薦(FCWeb)' | 'クライアントNG(挨拶実施後)'          | true
      '自己推薦(FCWeb)' | 'オファー連絡済'                      | true
      '自己推薦(FCWeb)' | 'WIN(マッチング)'                     | true
      '自己推薦(FCWeb)' | 'LOST(案件クローズ等)'                | false
      '自己推薦(FCWeb)' | '候補FC辞退'                          | false
      '自己推薦(FCWeb)' | 'LOST_候補'                           | true
      '自己推薦(FCWeb)' | 'LOST_エントリー対象'                 | true
      '自己推薦(FCWeb)' | 'LOST_エントリー打診済'               | true
      '自己推薦(FCWeb)' | 'LOST_FC辞退(CL挨拶前)'               | true
      '自己推薦(FCWeb)' | 'LOST_エントリー対象外'               | true
      '自己推薦(FCWeb)' | 'LOST_レジュメ提出済'                 | true
      '自己推薦(FCWeb)' | 'LOST_クライアントNG(レジュメ提出後)' | true
      '自己推薦(FCWeb)' | 'LOST_クライアント挨拶調整済'         | true
      '自己推薦(FCWeb)' | 'LOST_FC辞退手続中'                   | true
      '自己推薦(FCWeb)' | 'LOST_FC辞退(CL挨拶後)'               | true
      '自己推薦(FCWeb)' | 'LOST_クライアントNG(挨拶実施後)'     | true
      '自己推薦(FCWeb)' | 'LOST_オファー連絡済'                 | true
      '自己推薦(FCWeb)' | 'クローズ_重複'                       | false
      '営業推薦'        | '候補'                                | false
      '営業推薦'        | 'エントリー対象'                      | false
      '営業推薦'        | 'エントリー打診済'                    | false
      '営業推薦'        | 'FC辞退(CL挨拶前)'                    | false
      '営業推薦'        | 'エントリー対象外'                    | false
      '営業推薦'        | 'レジュメ提出済'                      | true
      '営業推薦'        | 'クライアントNG(レジュメ提出後)'      | true
      '営業推薦'        | 'クライアント挨拶調整済'              | true
      '営業推薦'        | 'FC辞退手続中'                        | true
      '営業推薦'        | 'FC辞退(CL挨拶後)'                    | true
      '営業推薦'        | 'クライアントNG(挨拶実施後)'          | true
      '営業推薦'        | 'オファー連絡済'                      | true
      '営業推薦'        | 'WIN(マッチング)'                     | true
      '営業推薦'        | 'LOST(案件クローズ等)'                | false
      '営業推薦'        | '候補FC辞退'                          | false
      '営業推薦'        | 'LOST_候補'                           | false
      '営業推薦'        | 'LOST_エントリー対象'                 | false
      '営業推薦'        | 'LOST_エントリー打診済'               | false
      '営業推薦'        | 'LOST_FC辞退(CL挨拶前)'               | false
      '営業推薦'        | 'LOST_エントリー対象外'               | false
      '営業推薦'        | 'LOST_レジュメ提出済'                 | true
      '営業推薦'        | 'LOST_クライアントNG(レジュメ提出後)' | true
      '営業推薦'        | 'LOST_クライアント挨拶調整済'         | true
      '営業推薦'        | 'LOST_FC辞退手続中'                   | true
      '営業推薦'        | 'LOST_FC辞退(CL挨拶後)'               | true
      '営業推薦'        | 'LOST_クライアントNG(挨拶実施後)'     | true
      '営業推薦'        | 'LOST_オファー連絡済'                 | true
      '営業推薦'        | 'クローズ_重複'                       | false
    end
    # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators

    with_them do
      let!(:matching) { FactoryBot.create(:matching, :with_project, :with_account, root__c: root, matching_status__c: status, project_trait:) }
      let(:project_trait) { [:with_publish_datetime] }

      it do
        expect(Matching.for_entry_history.include?(matching)).to eq(for_entry_history)
      end
    end
  end
end

# == Schema Information
#
# Table name: salesforce.matching__c
#
#  id                                   :integer          not null, primary key
#  _hc_err                              :text
#  _hc_lastop                           :string(32)
#  client_mtg_date__c                   :date
#  createdbyid                          :string(18)
#  createddate                          :datetime
#  datelog_clfcmtg__c                   :date
#  datelog_entryoffer__c                :date
#  datelog_resumeapply__c               :date
#  fc__c                                :string(18)
#  isactivewebentry__c                  :boolean
#  isdeleted                            :boolean
#  isstopstatuschangemail__c            :boolean
#  komento__c                           :string(255)
#  matching_status__c                   :string(255)
#  matchingkeyid__c                     :string(15)
#  name                                 :string(80)
#  ng_reoson_text__c                    :string(255)
#  opportunity__c                       :string(18)
#  recordtypeid                         :string(18)
#  referfromentrydate__c                :date
#  referfrommatching__c                 :string(18)
#  referfrommatchingstatus__c           :string(128)
#  referfrommodifier__c                 :string(18)
#  referfromrejumesentdate__c           :date
#  referfromroot__c                     :string(128)
#  refertomatching__c                   :string(18)
#  refertomatching__r__matchingkeyid__c :string(15)
#  root__c                              :string(255)
#  sfid                                 :string(18)
#  systemmodstamp                       :datetime
#
# Indexes
#
#  hc_idx_matching__c_fc__c                (fc__c)
#  hc_idx_matching__c_isactivewebentry__c  (isactivewebentry__c)
#  hc_idx_matching__c_opportunity__c       (opportunity__c)
#  hc_idx_matching__c_recordtypeid         (recordtypeid)
#  hc_idx_matching__c_refertomatching__c   (refertomatching__c)
#  hc_idx_matching__c_systemmodstamp       (systemmodstamp)
#  hcu_idx_matching__c_matchingkeyid__c    (matchingkeyid__c) UNIQUE
#  hcu_idx_matching__c_sfid                (sfid) UNIQUE
#
