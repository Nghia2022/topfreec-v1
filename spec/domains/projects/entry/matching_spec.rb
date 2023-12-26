# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::Entry::Matching, type: :model do
  describe 'validations' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let(:project) { FactoryBot.create(:project) }
    let(:matching) { Matching.new(account: fc_user.account, project:) }
    subject { ActiveType.cast(matching, described_class) }

    it do
      skip 'active_typeでfind_sti_classがオーバーライドされているため通らない' do
        is_expected.to validate_uniqueness_of(:opportunity__c).scoped_to(:fc__c)
      end
    end

    describe 'EntryValidator' do
      before do
        allow(subject.account.matchings).to receive_message_chain(:for_entry_count, :count).and_return(Settings.entry_limit)
      end

      it do
        subject.validate
        expect(subject.errors[:base]).to eq ['同時に7件以上の案件に応募することは出来ません。']
      end
    end

    describe '#reward_min' do
      it do
        is_expected.to allow_value(0, 123, 999).for(:reward_min)
          .and not_allow_value(-1).for(:reward_min)
          .and not_allow_value(1000).for(:reward_min)
          .and not_allow_value('').for(:reward_min)
      end
    end

    describe '#reward_desired' do
      it do
        is_expected.to allow_value(0, 123, 999).for(:reward_desired)
          .and not_allow_value(-1).for(:reward_desired)
          .and not_allow_value(1000).for(:reward_desired)
          .and not_allow_value('').for(:reward_desired)
      end
    end

    describe '#occupancy_rate' do
      it do
        is_expected
          .to validate_presence_of(:occupancy_rate)
      end
    end

    describe '#start_timing' do
      it do
        is_expected
          .to validate_presence_of(:start_timing)
      end

      context 'invalid' do
        it do
          subject
            .assign_attributes(start_timing: 1.day.ago)
          subject.validate
          expect(subject.errors[:start_timing]).to include('は現在より未来の日付を選択してください')
        end
      end
    end
  end

  describe '#entry' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, contact_trait:) }
    let(:contact_trait) { [] }
    let(:project) { FactoryBot.create(:project, :with_publish_datetime) }
    let(:matching) { Projects::Entry::Matching.new(project:, account: fc_user.account) }

    let(:sf_contact) { FactoryBot.build(:sf_contact, :fc) }
    let(:mws_user) { Salesforce::User.new(Email: 'test@example.com') }

    let(:valid_params) do
      {
        start_timing:   1.day.after.to_date,
        occupancy_rate: 100,
        reward_min:     10,
        reward_desired: 100
      }
    end

    let(:comment) do
      <<~COMMENT
        リリース予定日 #{I18n.l(params[:start_timing], format: :long)}
        最低報酬 10万円以上
        希望報酬 100万円
        稼働率 100%
      COMMENT
    end

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Restforce::Concerns::API).to receive(:select).and_return(mws_user)
    end

    subject(:perform) do
      matching.entry(fc_user, params)
      matching
    end

    context 'with valid params' do
      let(:params) { valid_params }
      let(:account) { fc_user.account }

      shared_examples 'update record' do
        it do
          expect do
            perform
            account.reload
          end.to change(account, :release_yotei_kakudo__c).from(nil).to('確定')
            .and change(account, :release_yotei__c).from(nil).to(release_yotei__c)
            .and change(account, :kado_ritsu__c).from(nil).to(params[:occupancy_rate])
        end
      end

      it do
        is_expected.to be_persisted
          .and have_attributes(isactivewebentry__c: true, komento__c: comment)
      end

      it do
        expect do
          perform_enqueued_jobs do
            perform
            MatchingStatusCheckJob.perform_now
          end
        end.to change { MatchingMailer.deliveries.count }.by(1)
      end

      context 'when adjust_start_timing is disabled' do
        let(:release_yotei__c) { params[:start_timing].to_date }

        include_examples 'update record'
      end

      context 'when adjust_start_timing is enabled' do
        let(:release_yotei__c) { 1.day.ago(params[:start_timing].to_date) }

        before do
          FeatureSwitch.enable :adjust_start_timing
        end

        include_examples 'update record'
      end

      context 'when start_timing and reward_desired are not changed' do
        let(:contact_trait) { :valid_data_for_register }
        let(:params) do
          { **valid_params, start_timing: account.release_yotei__c, reward_desired: account.kibo_hosyu__c }
        end

        it do
          expect do
            perform
          end.to(not_change { account.reload.kakunin_bi__c })
        end
      end

      context 'when start_timing is changed' do
        let(:contact_trait) { :valid_data_for_register }
        let(:params) do
          { **valid_params, start_timing: Date.current, reward_desired: account.kibo_hosyu__c }
        end

        it do
          expect do
            perform
          end.to(change { account.reload.kakunin_bi__c }.from(nil).to(Date.current))
        end
      end

      context 'when reward_desired is changed' do
        let(:contact_trait) { :valid_data_for_register }
        let(:params) do
          { **valid_params, start_timing: account.release_yotei__c, reward_desired: 100 }
        end

        it do
          expect do
            perform
          end.to(change { account.reload.kakunin_bi__c }.from(nil).to(Date.current))
        end
      end

      describe 'apply notification' do
        context 'When the same notification does not exist' do
          it do
            expect do
              perform
            end.to change(Notification, :count).by(1)
              .and change(Receipt, :count).by(1)
          end
        end

        context 'When the same notification exists' do
          let(:same_notification) { FactoryBot.create(:notification, kind: :matching_remaining) }
          let!(:same_notification_receipt) { FactoryBot.create(:receipt, notification: same_notification, receiver: fc_user) }

          let(:another_notification) { FactoryBot.create(:notification, kind: :direction_workflow) }
          let!(:another_notification_receipt) { FactoryBot.create(:receipt, notification: another_notification, receiver: fc_user) }

          it do
            expect do
              perform
            end.to not_change(Notification, :count)
              .and not_change(Receipt, :count)
              .and(change { Notification.find_by(id: same_notification.id) }.from(same_notification).to(nil))
              .and(not_change { Notification.find_by(id: another_notification.id) })
          end
        end
      end

      describe 'close duplicated entries' do
        let!(:duplicated_entry) { FactoryBot.create(:matching, project:, account: fc_user.account, root__c: :recommend_sales, matching_status__c: :candidate) }

        it do
          expect do
            perform
          end.to(change { duplicated_entry.reload.matching_status__c.to_sym }.from(:candidate).to(:closed_duplicated))
        end

        it do
          perform
          expect(Matching.last).to have_attributes(
            referfrommatching__c:       duplicated_entry.sfid,
            referfromroot__c:           duplicated_entry.root__c.value,
            referfrommatchingstatus__c: duplicated_entry.matching_status__c.value,
            referfrommodifier__c:       duplicated_entry.createdbyid,
            referfromentrydate__c:      duplicated_entry.datelog_entryoffer__c,
            referfromrejumesentdate__c: duplicated_entry.datelog_resumeapply__c,
            matchingkeyid__c:           be_present
          )
        end

        it do
          perform
          expect(duplicated_entry.reload).to have_attributes(
            refertomatching__r__matchingkeyid__c: Matching.last.matchingkeyid__c
          )
        end
      end

      describe 'transaction' do
        shared_examples 'failed to entry' do
          it do
            expect do
              perform_enqueued_jobs do
                subject
              end
            end.to not_change(matching, :persisted?)
              .and not_change(Notification, :count)
              .and not_change(Receipt, :count)
              .and(not_change { MatchingMailer.deliveries.count })
          end
        end

        context 'when failed to save record' do
          before do
            allow(matching).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          end

          it_behaves_like 'failed to entry'
        end

        context 'when failed to apply notification' do
          before do
            allow_any_instance_of(Notification).to receive(:notify).and_raise(ActiveRecord::RecordInvalid)
          end

          it_behaves_like 'failed to entry'
        end
      end
    end

    context 'with invalid params' do
      let(:params) { valid_params.merge(start_timing: nil) }

      it do
        is_expected.not_to be_persisted
      end
    end
  end

  describe '#comment' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let(:project) { FactoryBot.create(:project) }
    let(:matching) { Projects::Entry::Matching.new(project:, account: fc_user.account) }

    subject do
      ActiveType.cast(matching, described_class).tap do |record|
        record.assign_attributes(params)
      end.send(:comment)
    end

    let(:base_params) do
      {
        start_timing:   '2021-12-01',
        occupancy_rate: 20
      }
    end

    context 'without reward_min' do
      let(:params) { base_params }

      let(:comment) do
        <<~COMMENT
          リリース予定日 2021年12月1日
          最低報酬 指定なし
          希望報酬 指定なし
          稼働率 20%
        COMMENT
      end

      it { is_expected.to eq(comment) }
    end

    context 'with reward_min' do
      let(:params) { base_params.merge(reward_min: 50, reward_desired: 100) }

      let(:comment) do
        <<~COMMENT
          リリース予定日 2021年12月1日
          最低報酬 50万円以上
          希望報酬 100万円
          稼働率 20%
        COMMENT
      end

      it { is_expected.to eq(comment) }
    end
  end
end
