# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::EntryPolicy, type: :policy do
  subject { described_class.new(fc_user, model) }
  let(:model) { Matching.new(project:).decorate }
  let(:project) { FactoryBot.create(:project, :with_publish_datetime) }

  describe 'fc user' do
    context 'activated' do
      let(:fc_user) { FactoryBot.create(:fc_user, :activated) }

      context 'when matching not exists' do
        it do
          is_expected.to permit_actions(%i[new create])
        end
      end

      context 'when matching exists' do
        let!(:matching) { FactoryBot.create(:matching, account: fc_user.account, project:, root__c: root, matching_status__c: matching_status) }

        using RSpec::Parameterized::TableSyntax

        # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
        where(:root, :matching_status, :forbid) do
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
          it do
            if forbid
              is_expected.to forbid_actions(%i[new create])
            else
              is_expected.to permit_actions(%i[new create])
            end
          end
        end
      end

      context 'when entry is closed' do
        let(:project) { FactoryBot.build_stubbed(:project, isclosedwebreception__c: true) }

        it do
          is_expected.to forbid_actions(%i[new create])
        end
      end

      describe '#permitted_attributes' do
        it do
          is_expected.to permit_mass_assignment_of(%i[start_timing reward_min occupancy_rate])
        end
      end
    end
  end
end
