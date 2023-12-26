# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchingEvent, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:matching) }
  end

  describe '#status_changed?' do
    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    where(:old_status, :new_status, :changed) do
      :nil       | :candidate         | true
      :candidate | :candidate         | false
      :candidate | :fc_declined_entry | true
    end
    # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

    with_them do
      let(:matching_event) { FactoryBot.build(:matching_event, old_status:, new_status:) }

      it do
        expect(matching_event.send(:status_changed?)).to eq(changed)
      end
    end
  end

  describe '#notification_target_status?' do
    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
    where(:root, :new_status, :is_target) do
      '自己推薦(FCWeb)' | '候補'                                | true
      '自己推薦(FCWeb)' | 'エントリー対象'                      | false
      '自己推薦(FCWeb)' | 'エントリー打診済'                    | false
      '自己推薦(FCWeb)' | 'FC辞退(CL挨拶前)'                    | true
      '自己推薦(FCWeb)' | 'エントリー対象外'                    | true
      '自己推薦(FCWeb)' | 'レジュメ提出済'                      | false
      '自己推薦(FCWeb)' | 'クライアントNG(レジュメ提出後)'      | true
      '自己推薦(FCWeb)' | 'クライアント挨拶調整済'              | false
      '自己推薦(FCWeb)' | 'FC辞退手続中'                        | true
      '自己推薦(FCWeb)' | 'FC辞退(CL挨拶後)'                    | true
      '自己推薦(FCWeb)' | 'クライアントNG(挨拶実施後)'          | false
      '自己推薦(FCWeb)' | 'オファー連絡済'                      | false
      '自己推薦(FCWeb)' | 'WIN(マッチング)'                     | false
      '自己推薦(FCWeb)' | 'LOST(案件クローズ等)'                | false
      '自己推薦(FCWeb)' | '候補FC辞退'                          | false
      '自己推薦(FCWeb)' | 'LOST_候補'                           | true
      '自己推薦(FCWeb)' | 'LOST_エントリー対象'                 | true
      '自己推薦(FCWeb)' | 'LOST_エントリー打診済'               | true
      '自己推薦(FCWeb)' | 'LOST_FC辞退(CL挨拶前)'               | false
      '自己推薦(FCWeb)' | 'LOST_エントリー対象外'               | false
      '自己推薦(FCWeb)' | 'LOST_レジュメ提出済'                 | true
      '自己推薦(FCWeb)' | 'LOST_クライアントNG(レジュメ提出後)' | false
      '自己推薦(FCWeb)' | 'LOST_クライアント挨拶調整済'         | false
      '自己推薦(FCWeb)' | 'LOST_FC辞退手続中'                   | false
      '自己推薦(FCWeb)' | 'LOST_FC辞退(CL挨拶後)'               | false
      '自己推薦(FCWeb)' | 'LOST_クライアントNG(挨拶実施後)'     | false
      '自己推薦(FCWeb)' | 'LOST_オファー連絡済'                 | false
      '自己推薦(FCWeb)' | 'クローズ_重複'                       | false
      '営業推薦'        | '候補'                                | false
      '営業推薦'        | 'エントリー対象'                      | false
      '営業推薦'        | 'エントリー打診済'                    | false
      '営業推薦'        | 'FC辞退(CL挨拶前)'                    | false
      '営業推薦'        | 'エントリー対象外'                    | false
      '営業推薦'        | 'レジュメ提出済'                      | false
      '営業推薦'        | 'クライアントNG(レジュメ提出後)'      | true
      '営業推薦'        | 'クライアント挨拶調整済'              | false
      '営業推薦'        | 'FC辞退手続中'                        | true
      '営業推薦'        | 'FC辞退(CL挨拶後)'                    | true
      '営業推薦'        | 'クライアントNG(挨拶実施後)'          | false
      '営業推薦'        | 'オファー連絡済'                      | false
      '営業推薦'        | 'WIN(マッチング)'                     | false
      '営業推薦'        | 'LOST(案件クローズ等)'                | false
      '営業推薦'        | '候補FC辞退'                          | false
      '営業推薦'        | 'LOST_候補'                           | false
      '営業推薦'        | 'LOST_エントリー対象'                 | false
      '営業推薦'        | 'LOST_エントリー打診済'               | false
      '営業推薦'        | 'LOST_FC辞退(CL挨拶前)'               | false
      '営業推薦'        | 'LOST_エントリー対象外'               | false
      '営業推薦'        | 'LOST_レジュメ提出済'                 | true
      '営業推薦'        | 'LOST_クライアントNG(レジュメ提出後)' | false
      '営業推薦'        | 'LOST_クライアント挨拶調整済'         | false
      '営業推薦'        | 'LOST_FC辞退手続中'                   | false
      '営業推薦'        | 'LOST_FC辞退(CL挨拶後)'               | false
      '営業推薦'        | 'LOST_クライアントNG(挨拶実施後)'     | false
      '営業推薦'        | 'LOST_オファー連絡済'                 | false
      '営業推薦'        | 'クローズ_重複'                       | false
    end
    # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators

    with_them do
      let(:matching_event) { FactoryBot.build(:matching_event, root:, old_status: nil, new_status:) }

      it do
        expect(matching_event.send(:notification_target_status?)).to eq(is_target)
      end
    end
  end

  describe '#notifiable_fc_user?' do
    let(:matching_event) { FactoryBot.build(:matching_event, matching:) }
    let(:matching) { FactoryBot.build(:matching, account: contact.account) }

    subject do
      matching_event.send(:notifiable_fc_user?)
    end

    context 'when account is released and has email' do
      let(:contact) { FactoryBot.create(:contact, :fc) }

      it do
        is_expected.to eq(true)
      end
    end

    context 'when account is released and has no email' do
      let(:contact) { FactoryBot.create(:contact, :fc, web_loginemail__c: '') }

      it do
        is_expected.to eq(false)
      end
    end

    context 'when account is not released' do
      let(:contact) { FactoryBot.create(:contact, :fc, account_fc_trait: [:unreleased]) }

      it do
        is_expected.to eq(false)
      end
    end
  end

  describe '#published_project?' do
    let(:matching_event) { FactoryBot.build(:matching_event, matching:) }
    let(:matching) { FactoryBot.build(:matching, project:) }

    subject do
      matching_event.send(:published_project?)
    end

    context 'when project is published' do
      let(:project) { FactoryBot.create(:project, :with_publish_datetime) }

      it do
        is_expected.to eq(true)
      end
    end

    context 'when project is not published' do
      let(:project) { FactoryBot.create(:project) }

      it do
        is_expected.to eq(false)
      end
    end
  end

  describe '#notifiable_matching?' do
    using RSpec::Parameterized::TableSyntax

    let(:matching_event) { FactoryBot.build(:matching_event, matching:, old_status: nil, new_status:) }

    subject do
      matching_event.send(:notifiable_matching?)
    end

    context 'when matching is able to send email' do
      let(:matching) { FactoryBot.build(:matching) }

      # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
      where(:new_status, :is_target) do
        '候補'                           | true
        'エントリー対象外'               | true
        'FC辞退(CL挨拶前)'               | true
        'クライアントNG(レジュメ提出後)' | true
        'FC辞退手続中'                   | true
        'FC辞退(CL挨拶後)'               | true
        'LOST_候補'                      | true
        'LOST_エントリー対象'            | true
        'LOST_エントリー打診済'          | true
        'LOST_レジュメ提出済'            | true
      end
      # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators

      with_them do
        it do
          is_expected.to eq(is_target)
        end
      end
    end

    context 'when matching is not able to send email' do
      let(:matching) { FactoryBot.build(:matching, :with_status_of_stop_email) }

      # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators
      where(:new_status, :is_target) do
        '候補'                           | false
        'エントリー対象外'               | false
        'FC辞退(CL挨拶前)'               | true
        'クライアントNG(レジュメ提出後)' | false
        'FC辞退手続中'                   | true
        'FC辞退(CL挨拶後)'               | true
        'LOST_候補'                      | false
        'LOST_エントリー対象'            | false
        'LOST_エントリー打診済'          | false
        'LOST_レジュメ提出済'            | false
      end
      # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators

      with_them do
        it do
          is_expected.to eq(is_target)
        end
      end
    end
  end

  describe '#ingnored_operation?' do
    using RSpec::Parameterized::TableSyntax

    # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    where(:old_hc_lastop, :new_hc_lastop, :new_status, :ignored) do
      'SYNCED'   | 'SYNCED' | 'FC辞退(CL挨拶前)' | true
      'SYNCED'   | 'SYNCED' | 'FC辞退手続中'     | true
      'SYNCED'   | 'SYNCED' | 'FC辞退(CL挨拶後)' | false
      nil        | 'SYNCED' | 'FC辞退(CL挨拶前)' | false
      'SYNCED'   | nil      | 'FC辞退(CL挨拶前)' | false
    end
    # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

    with_them do
      let(:matching_event) { FactoryBot.build(:matching_event, new_status:, old_hc_lastop:, new_hc_lastop:) }

      it do
        expect(matching_event.send(:ignored_operation?)).to eq(ignored)
      end
    end
  end

  describe 'status' do
    let(:matching_event) { FactoryBot.create(:matching_event, matching:) }
    let(:matching) { FactoryBot.create(:matching, :with_project, :with_account) }

    context 'with invalid value' do
      let(:status) { '存在しない値' }

      before do
        matching_event.update_columns(old_status: status, new_status: status) # rubocop:disable Rails/SkipsModelValidations
        matching_event.reload
      end

      it do
        expect(matching_event.old_status).to eq(status)
      end

      it do
        expect(matching_event.new_status).to eq(status)
      end
    end
  end
end

# == Schema Information
#
# Table name: matching_events
#
#  id            :bigint           not null, primary key
#  new_hc_lastop :string
#  new_status    :string
#  old_hc_lastop :string
#  old_status    :string
#  root          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  matching_id   :integer
#
# Indexes
#
#  index_matching_events_on_matching_id  (matching_id)
#
