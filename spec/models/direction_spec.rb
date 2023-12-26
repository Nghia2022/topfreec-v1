# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Direction, type: :model do
  it_behaves_like 'sobject', 'Direction__c'
  describe 'associations' do
    it do
      is_expected.to belong_to(:project).with_foreign_key(:opportunity__c).with_primary_key(:sfid)
    end
  end

  describe 'delegations' do
    it do
      is_expected.to delegate_method(:name).to(:project).with_prefix.allow_nil
    end
  end

  describe 'enumerize' do
    it do
      is_expected.to enumerize(:status__c).in(
        in_prepare: '準備中',
        rejected:   '差戻し'
      ).with_default(:in_prepare)
    end
  end

  describe 'aasm' do
    using RSpec::Parameterized::TableSyntax

    subject { direction }
    let(:project) do
      FactoryBot.create(:project,
                        client:                    client_user.account,
                        fc_account:                fc_user.account,
                        main_cl_contact:           client_user.contact,
                        main_fc_contact:           fc_user.contact,
                        mws_gyomusekinin_sub_c__c: sf_user.Id)
    end
    let(:direction) { FactoryBot.create(:direction, trait, project:, directionmonth__c: '2020年10月') }
    let(:value_hash) { Direction.status__c.instance_variable_get(:@value_hash) }
    named_let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    named_let(:client_user) { FactoryBot.create(:client_user, :with_contact) }
    let(:sf_contact_fc) { ProfileDecorator.decorate(FactoryBot.build(:sf_contact, Id: fc_user.contact.sfid, Web_LoginEmail__c: fc_user.email)) }
    let(:sf_contact_cl) { ProfileDecorator.decorate(FactoryBot.build(:sf_contact, Id: client_user.contact.sfid, Web_LoginEmail__c: client_user.email)) }
    let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
    let(:sf_account_cl) { FactoryBot.build(:sf_account_client) }
    let(:sf_user) { FactoryBot.build_stubbed(:sf_user) }
    let(:main_mws_user) { FactoryBot.build(:sf_user) }
    let(:sub_mws_user) { FactoryBot.build(:sf_user) }
    let(:task_params) { anything }

    let(:client_presenter_builder) do
      ActiveType.cast(direction, Client::ManageDirection::Direction).then do |this|
        Client::ManageDirection::DirectionMailerPresenterBuilder.new(this).tap do |builder|
          allow(builder).to receive(:sf_contacts).and_return([sf_contact_cl])
          allow(builder).to receive(:fc_account).and_return(sf_account_fc)
          allow(builder).to receive(:main_mws_user).and_return(main_mws_user)
          allow(builder).to receive(:sub_mws_user).and_return(sub_mws_user)
        end
      end
    end
    let(:fc_presenter_builder) do
      ActiveType.cast(direction, Client::ManageDirection::Direction).then do |this|
        Fc::ManageDirection::DirectionMailerPresenterBuilder.new(this).tap do |builder|
          allow(builder).to receive(:sf_contacts).and_return([sf_contact_fc])
          allow(builder).to receive(:fc_account).and_return(sf_account_fc)
          allow(builder).to receive(:main_mws_user).and_return(main_mws_user)
          allow(builder).to receive(:sub_mws_user).and_return(sub_mws_user)
        end
      end
    end

    shared_context 'create task in salesforce' do
      before do
        stub_salesforce_create_request('Task', task_params)
      end
    end

    shared_examples 'fire event' do
      it do
        expect do
          subject
        end.to change(Notification, :count).by(1)
          .and change(Receipt, :count).by(1)
      end

      describe 'applied notification' do
        subject do
          fire_event
          Notification.last
        end

        it do
          is_expected.to have_attributes(subject: notification_subject, kind: 'direction_workflow')
            .and(satisfy { |this| this.receipts.where(receiver: fc_user).count == 1 })
        end
      end
    end

    describe '#request_confirmation_to_client' do
      include_context 'create task in salesforce'

      let(:direction) { FactoryBot.build(:direction, :in_prepare, project:) }

      before do
        allow(client_user.contact).to receive(:to_sobject).and_return(sf_contact_cl)
        allow(Client::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(client_presenter_builder)
      end

      it do
        travel_to Time.zone.parse('2020-10-29 10:00') do
          direction.request_confirmation_to_client!

          is_expected.to have_attributes(requestdatetime__c: Time.zone.parse('2020-10-29 10:00'), ismailqueue__c: false)
        end
      end

      it do
        expect do
          perform_enqueued_jobs do
            direction.request_confirmation_to_client!
          end
        end.to change { DirectionMailer.deliveries.count }.by(1)
      end

      it do
        perform_enqueued_jobs do
          direction.request_confirmation_to_client!
        end

        email = open_email(sf_contact_cl.web_login_email)

        expect(email).to deliver_to(sf_contact_cl.web_login_email)
          .and have_subject('【みらいワークス】業務指示内容確認のお願い')
      end
    end

    describe '#approve_by_client' do
      include_context 'create task in salesforce'

      where(:status_from, :status_to, :trait) do
        '準備中'   | nil | :in_prepare
        'FC確認中' | nil | :waiting_for_fc
        '差戻し'   | nil | :rejected_by_client
        '完了' | nil | :completed
      end

      with_them do
        it do
          expect(direction).to_not allow_event(:approve_by_client, client_user)
        end
      end

      context 'when transition from valid status' do
        let(:direction) { FactoryBot.build(:direction, :waiting_for_client, project:, directionmonth__c: '2020年10月', autoapprschedule_cl__c: '2020-10-08') }

        before do
          allow(Client::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(client_presenter_builder)
          allow(Fc::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(fc_presenter_builder)
        end

        it do
          is_expected.to transition_from(:waiting_for_client).to(:waiting_for_fc).on_event(:approve_by_client, client_user:, sf_contact: sf_contact_cl)
        end

        describe 'store attributes' do
          it do
            travel_to(Time.zone.parse('2020-10-29 10:00')) do
              direction.approve_by_client(client_user:, sf_contact: sf_contact_cl)

              is_expected.to have_attributes(
                status__c:              'waiting_for_fc',
                approveddatebycl__c:    Time.zone.parse('2020-10-29 10:00'),
                isapprovedbycl__c:      true,
                approverofcl__c:        sf_contact_cl.full_name,
                autoapprschedule_cl__c: nil,
                autoapprschedule_fc__c: Date.parse('2020-11-06')
              )
            end
          end
        end

        it_behaves_like 'fire event' do
          subject(:fire_event) { direction.approve_by_client!(client_user:, sf_contact: sf_contact_cl) }
          let(:notification_subject) { '業務指示内容のご確認をお願いいたします。' }

          it do
            expect do
              perform_enqueued_jobs do
                fire_event
              end
            end.to change { DirectionMailer.deliveries.count }.by(2)
          end

          describe 'deliver email to client and fc' do
            subject do
              perform_enqueued_jobs do
                fire_event
              end
            end

            let(:email_for_client) { open_email(sf_contact_cl.web_login_email) }
            let(:email_for_fc) { open_email(sf_contact_fc.web_login_email) }

            it do
              is_expected
                .to satisfy { email_for_client.subject == '【みらいワークス】業務指示内容確認完了案内' }
                .and(satisfy { email_for_fc.subject == '【みらいワークス】業務指示内容確認のお願い' })
            end
          end
        end
      end
    end

    describe '#reject_by_client' do
      include_context 'create task in salesforce'

      where(:status_from, :status_to, :trait, :valid) do
        'クライアント確認中' | '差戻し' | :waiting_for_client | true
        '差し戻し' | '差戻し' | :rejected_by_client | false
        'FC確認中' | '差戻し' | :waiting_for_fc | false
        '完了' | '差戻し' | :completed | false
      end

      with_them do
        it do
          if valid
            expect(direction).to transition_from(value_hash[status_from].to_sym).to(value_hash[status_to].to_sym).on_event(:reject_by_client, params: {}, client_user:, sf_contact: sf_contact_cl)
          else
            expect(direction).to_not allow_event(:reject_by_client, client_user, {})
          end
        end
      end

      context 'when rejected' do
        let(:direction) do
          ActiveType.cast(
            FactoryBot.build(:direction, :waiting_for_client, project:, directionmonth__c: '2020年10月'),
            Client::ManageDirection::Direction
          )
        end
        let(:params) do
          {
            new_direction_detail: 'new direction detail'
          }
        end

        before do
          allow(Client::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(client_presenter_builder)
        end

        describe 'store attributes' do
          it do
            travel_to(Time.zone.parse('2020-10-29 10:00')) do
              direction.reject_by_client(params:, client_user:, sf_contact: sf_contact_cl)

              is_expected.to have_attributes(
                status__c:              'rejected',
                isapprovedbycl__c:      false,
                changedhistories__c:    "[CL修正依頼：2020-10-29 10:00]\r\n#{params[:new_direction_detail]}",
                autoapprschedule_cl__c: nil,
                autoapprschedule_fc__c: nil,
                newdirectiondetail__c:  params[:new_direction_detail]
              )
            end
          end
        end

        it do
          expect do
            perform_enqueued_jobs do
              direction.reject_by_client!(params:, client_user:, sf_contact: sf_contact_cl)
            end
          end.to change { DirectionMailer.deliveries.count }.by(1)
        end
      end
    end

    describe '#request_reconfirmation_to_client' do
      let(:trait) { :rejected_by_client }

      include_context 'create task in salesforce' do
        let(:task_params) do
          {
            Subject:      "「#{project.name}」#{direction.directionmonth__c} 分の業務責任者活動を開始",
            Status:       '完了',
            EigyoType__c: 'クライアントフォロー',
            ActivityDate: Date.current.as_json,
            Description:  "#{sf_contact_cl.full_name} へ 「#{project.name}」#{direction.directionmonth__c} 分 の業務指示確認依頼を送信",
            OwnerId:      project.mws_gyomusekinin_sub_c__c,
            Priority:     '中',
            WhatId:       project.sfid
          }.stringify_keys
        end
      end

      before do
        allow(client_user.contact).to receive(:to_sobject).and_return(sf_contact_cl)
        allow(Client::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(client_presenter_builder)
      end

      around do |ex|
        travel_to(Time.zone.parse('2020-10-29 10:00')) { ex.run }
      end

      before do
        allow(client_user.contact).to receive(:to_sobject).and_return(sf_contact_cl)
      end

      it do
        is_expected.to allow_event(:request_reconfirmation_to_client)
      end

      describe 'store attributes' do
        it do
          direction.request_reconfirmation_to_client!

          is_expected.to have_attributes(
            status__c:              'waiting_for_client',
            requestdatetime__c:     Time.zone.parse('2020-10-29 10:00'),
            autoapprschedule_cl__c: Date.parse('2020-11-06'),
            ismailqueue__c:         false
          )
        end
      end

      it do
        expect do
          perform_enqueued_jobs do
            direction.request_reconfirmation_to_client!
          end
        end.to change { DirectionMailer.deliveries.count }.by(1)
      end

      it do
        perform_enqueued_jobs do
          direction.request_reconfirmation_to_client!
        end

        email = open_email(sf_contact_cl.web_login_email)

        expect(email).to deliver_to(sf_contact_cl.web_login_email)
          .and have_subject('【みらいワークス】業務指示内容確認のお願い（修正版)')
      end
    end

    describe '#auto_approve_by_client' do
      include_context 'create task in salesforce'

      let(:trait) { :waiting_for_client }

      before do
        allow(client_user.contact).to receive(:to_sobject).and_return(sf_contact_cl)

        allow(Client::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(client_presenter_builder)
        allow(Fc::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(fc_presenter_builder)
      end

      describe 'store attributes' do
        it do
          travel_to Time.zone.parse('2020-10-29 10:00') do
            direction.auto_approve_by_client

            is_expected.to have_attributes(
              approveddatebycl__c:    Time.zone.parse('2020-10-29 10:00'),
              isapprovedbycl__c:      true,
              approverofcl__c:        sf_contact_cl.full_name,
              autoapprschedule_fc__c: Date.parse('2020-11-06')
            )
          end
        end
      end

      it do
        expect do
          perform_enqueued_jobs do
            direction.auto_approve_by_client!
          end
        end.to change { DirectionMailer.deliveries.count }.by(2)
      end

      it do
        perform_enqueued_jobs do
          direction.auto_approve_by_client!
        end

        email = open_email(sf_contact_cl.web_login_email)

        expect(email).to deliver_to(sf_contact_cl.web_login_email)
          .and have_subject('【みらいワークス】業務指示内容確認完了ご通知')
      end
    end

    describe '#approve_by_fc' do
      include_context 'create task in salesforce'

      before do
        allow(fc_user.contact).to receive(:to_sobject).and_return(sf_contact_fc)
      end

      context 'when transition from valid status' do
        let(:direction) { FactoryBot.build(:direction, :waiting_for_fc, project:, directionmonth__c: '2020年10月') }

        before do
          allow(Fc::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(fc_presenter_builder)
        end

        it do
          is_expected.to transition_from(:waiting_for_fc).to(:completed).on_event(:approve_by_fc, fc_user:, sf_contact: sf_contact_fc)
            .and(satisfy { |direction| direction.approveroffc__c == sf_contact_fc.full_name })
        end

        describe 'store attributes' do
          it do
            travel_to Time.zone.parse('2020-10-29 10:00') do
              direction.approve_by_fc(fc_user:, sf_contact: sf_contact_fc)

              is_expected.to have_attributes(
                status__c:              'completed',
                isapprovedbyfc__c:      true,
                approveroffc__c:        sf_contact_fc.full_name,
                approveddatebyfc__c:    Time.zone.parse('2020-10-29 10:00'),
                autoapprschedule_cl__c: nil,
                autoapprschedule_fc__c: nil
              )
            end
          end
        end

        it do
          expect do
            perform_enqueued_jobs do
              direction.approve_by_fc!(fc_user:, sf_contact: sf_contact_fc)
            end
          end.to change { DirectionMailer.deliveries.count }.by(1)
        end

        it_behaves_like 'fire event' do
          subject(:fire_event) { direction.approve_by_fc!(fc_user:, sf_contact: sf_contact_fc) }
          let(:notification_subject) { '業務指示内容が確定しました。' }
        end
      end

      context 'when transition from invalid status' do
        # rubocop:disable Layout/ExtraSpacing, Layout/SpaceAroundOperators, Lint/BinaryOperatorWithIdenticalOperands
        where(:status_from, :status_to, :trait) do
          '完了'     | '完了' | :completed
          '差戻し'   | '完了' | :rejected_by_fc
        end
        # rubocop:enable Layout/ExtraSpacing, Layout/SpaceAroundOperators, Lint/BinaryOperatorWithIdenticalOperands

        with_them do
          it do
            expect(direction).to_not allow_event(:approve_by_fc, fc_user:)
          end
        end
      end
    end

    describe '#reject_by_fc' do
      include_context 'create task in salesforce'

      context 'when transition from valid status' do
        where(:status_from, :status_to, :trait) do
          'FC確認中' | '差戻し' | :waiting_for_fc
        end

        with_them do
          it do
            is_expected.to transition_from(value_hash[status_from].to_sym).to(value_hash[status_to].to_sym).on_event(:reject_by_fc, params: {}, fc_user:, sf_contact: sf_contact_fc)
          end
        end
      end

      context 'when transition from invalid status' do
        # rubocop:disable Layout/SpaceAroundOperators
        where(:status_from, :status_to, :trait) do
          '差し戻し' | '差戻し' | :rejected_by_fc
          '完了'     | '差戻し' | :completed
        end
        # rubocop:enable Layout/SpaceAroundOperators

        with_them do
          it do
            expect(direction).to_not allow_event(:reject_by_fc, params: {}, fc_user:, sf_contact: sf_contact_fc)
          end
        end
      end

      context 'when rejected' do
        let(:direction) do
          ActiveType.cast(
            FactoryBot.build(:direction, :waiting_for_fc, project:, directionmonth__c: '2020年10月'),
            Fc::ManageDirection::Direction
          )
        end
        let(:params) do
          {
            comment_from_fc: 'comment'
          }
        end

        before do
          allow(Fc::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(fc_presenter_builder)
        end

        describe 'store attributes' do
          it do
            travel_to Time.zone.parse('2020-10-29 10:00') do
              direction.reject_by_fc(fc_user:, params:, sf_contact: sf_contact_fc)

              is_expected.to have_attributes(
                status__c:              'rejected',
                isapprovedbycl__c:      false,
                changedhistories__c:    "[FCコメント：2020-10-29 10:00]\r\n#{params[:comment_from_fc]}",
                autoapprschedule_cl__c: nil,
                autoapprschedule_fc__c: nil
              )
            end
          end
        end

        it do
          expect do
            perform_enqueued_jobs do
              direction.reject_by_fc!(fc_user:, params:, sf_contact: sf_contact_fc)
            end
          end.to change { DirectionMailer.deliveries.count }.by(1)
        end
      end
    end

    describe '#auto_approve_by_fc' do
      include_context 'create task in salesforce'

      let(:trait) { :waiting_for_fc }

      before do
        allow(fc_user.contact).to receive(:to_sobject).and_return(sf_contact_fc)
        allow(Fc::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(fc_presenter_builder)
      end

      describe 'store attributes' do
        it do
          travel_to Time.zone.parse('2020-10-29 10:00') do
            direction.auto_approve_by_fc

            is_expected.to have_attributes(
              status__c:                  'completed',
              isapprovedbyfc__c:          true,
              approveroffc__c:            sf_contact_fc.full_name,
              approveddatebyfc__c:        Time.zone.parse('2020-10-29 10:00'),
              autoapprschedule_cl__c:     nil,
              autoapprschedule_fc__c:     nil,
              autoapproveddatetime_fc__c: Time.zone.parse('2020-10-29 10:00')
            )
          end
        end
      end

      it do
        expect do
          perform_enqueued_jobs do
            direction.auto_approve_by_fc!
          end
        end.to change { DirectionMailer.deliveries.count }.by(1)
      end

      it do
        perform_enqueued_jobs do
          direction.auto_approve_by_fc!
        end

        email = open_email(sf_contact_fc.web_login_email)

        expect(email).to deliver_to(sf_contact_fc.web_login_email)
          .and have_subject('【みらいワークス】業務指示内容確認完了ご通知')
      end
    end

    describe '#finalize_by_mws' do
      let(:trait) { :completed }

      it do
        is_expected.to allow_event(:finalize_by_mws)
      end

      context 'when transition from valid status' do
        it_behaves_like 'fire event' do
          subject(:fire_event) { direction.finalize_by_mws! }
          let(:notification_subject) { '業務指示内容が確定しました。' }
        end
      end
    end
  end

  describe 'triggers' do
    let(:project) { FactoryBot.create(:project) }

    describe 'after insert' do
      let(:direction) { FactoryBot.build(:direction, project:, status__c: :in_prepare, _hc_lastop: 'SYNCED') }

      it do
        expect do
          direction.save
        end.to change(DirectionEvent, :count).by(1)
      end
    end

    describe 'after update ismailqueue__c' do
      let!(:direction) { FactoryBot.create(:direction, project:, status__c: :in_prepare, _hc_lastop: 'SYNCED') }

      # _hc_lastop=SYNCEDの場合はSalesforceからの更新だが、UPDATE直後はPENDINGのため、
      # このタイミングではDirectionEventは作成されないはずなので、このテストはおかしい
      xit do
        expect do
          direction.update(ismailqueue__c: true)
        end.to change(DirectionEvent, :count).by(1)
      end

      context 'when update status__c and ismailqueue__c' do
        # _hc_lastop=SYNCEDの場合はSalesforceからの更新だが、UPDATE直後はPENDINGのため、
        # このタイミングではDirectionEventは作成されないはずなので、このテストはおかしい
        xit do
          expect do
            direction.update(status__c: :waiting_for_client, ismailqueue__c: true)
          end.to change(DirectionEvent, :count).by(1)
        end
      end
    end

    describe 'after update status__c' do
      let!(:direction) { FactoryBot.create(:direction, project:, status__c: :in_prepare, _hc_lastop: 'SYNCED') }

      # _hc_lastop=SYNCEDの場合はSalesforceからの更新だが、UPDATE直後はPENDINGのため、
      # このタイミングではDirectionEventは作成されないはずなので、このテストはおかしい
      xit do
        expect do
          direction.update(status__c: :waiting_for_client)
        end.to change(DirectionEvent, :count).by(1)
      end

      xit do
        direction.update(status__c: :waiting_for_client)

        expect(DirectionEvent.last).to have_attributes(
          direction_id:   direction.id,
          direction_sfid: direction.sfid,
          old_status:     'in_prepare',
          new_status:     'waiting_for_client'
        )
      end
    end
  end

  describe 'publish tasks' do
    let(:project) do
      FactoryBot.create(:project,
                        client:                    client_user.account,
                        main_cl_contact:           client_user.contact,
                        main_fc_contact:           fc_user.contact,
                        mws_gyomusekinin_sub_c__c: sf_user.Id)
    end
    let(:direction) { FactoryBot.create(:direction, trait, project:, directionmonth__c: '2020年10月') }
    named_let(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    named_let(:client_user) { FactoryBot.create(:client_user, :with_contact) }
    named_let(:sf_contact_fc) { ProfileDecorator.decorate(FactoryBot.build(:sf_contact)) }
    named_let(:sf_contact_cl) { ProfileDecorator.decorate(FactoryBot.build(:sf_contact)) }
    let(:sf_user) { FactoryBot.build_stubbed(:sf_user) }

    before do
      allow(Tasks::RequestConfirmationToClientTask).to receive(:sf_contact).and_return(sf_contact_cl)
    end

    describe '#publish_request_confirmation_to_client_task' do
      let(:trait) { :waiting_for_client }
      let(:task_params) do
        {
          Subject:      "「#{project.name}」#{direction.directionmonth__c} 分の業務責任者活動を開始",
          Status:       '完了',
          EigyoType__c: 'クライアントフォロー',
          ActivityDate: Date.current.as_json,
          Description:  "#{sf_contact_cl.full_name} へ 「#{project.name}」#{direction.directionmonth__c} 分 の業務指示確認依頼を送信",
          OwnerId:      project.mws_gyomusekinin_sub_c__c,
          Priority:     '中',
          WhatId:       project.sfid
        }.stringify_keys
      end

      it do
        stub_salesforce_create_request('Task', task_params)
        direction.publish_request_confirmation_to_client_task
      end
    end

    describe '#publish_approved_by_client_task' do
      let(:trait) { :waiting_for_client }
      let(:task_params) do
        {
          Subject:      "[CL]#{direction.directionmonth__c} 分の業務指示内容の確認完了",
          Status:       '完了',
          EigyoType__c: 'クライアントフォロー',
          ActivityDate: Date.current.as_json,
          Description:  "#{sf_contact_cl.full_name}が「#{project.name}」#{direction.directionmonth__c} 分業務指示内容の確認を完了しました。",
          OwnerId:      project.mws_gyomusekinin_sub_c__c,
          Priority:     '中',
          WhatId:       project.sfid
        }.stringify_keys
      end

      it do
        stub_salesforce_create_request('Task', task_params)
        direction.publish_approved_by_client_task(sf_contact: sf_contact_cl)
      end
    end

    describe '#publish_rejected_by_client_task' do
      let(:trait) { :waiting_for_client }
      let(:task_params) do
        {
          Subject:      '[CL]業務指示内容の修正依頼',
          Status:       '完了',
          EigyoType__c: 'クライアントフォロー',
          ActivityDate: Date.current.as_json,
          Description:  "#{sf_contact_cl.full_name}から「#{project.name}」#{direction.directionmonth__c} 分業務内容の修正依頼がありました。修正内容は業務責任者オブジェクトをご確認ください。",
          OwnerId:      project.mws_gyomusekinin_sub_c__c,
          Priority:     '中',
          WhatId:       project.sfid
        }.stringify_keys
      end

      it do
        stub_salesforce_create_request('Task', task_params)
        direction.publish_rejected_by_client_task(sf_contact: sf_contact_cl)
      end
    end

    describe '#publish_auto_approved_by_client_task' do
      let(:trait) { :waiting_for_client }
      let(:task_params) do
        {
          Subject:      '[CL]業務指示内容の自動確認',
          Status:       '完了',
          EigyoType__c: 'クライアントフォロー',
          ActivityDate: Date.current.as_json,
          Description:  "「#{project.name}」#{direction.directionmonth__c} 分の業務指示内容が自動確認されました。",
          OwnerId:      project.mws_gyomusekinin_sub_c__c,
          Priority:     '中',
          WhatId:       project.sfid
        }.stringify_keys
      end

      it do
        stub_salesforce_create_request('Task', task_params)
        direction.publish_auto_approved_by_client_task
      end
    end

    describe '#publish_approved_by_fc_task' do
      let(:direction) { FactoryBot.create(:direction, trait, project:, directionmonth__c: '2020年10月', approveddatebyfc__c: Date.current) }
      let(:trait) { :waiting_for_fc }
      let(:task_params) do
        {
          Subject:         "[FC]#{direction.directionmonth__c} 分の業務指示内容の確認完了",
          Status:          '完了',
          EigyoType__c:    'FCフォロー',
          ActivityDate:    Date.current.as_json,
          Description:     "#{sf_contact_fc.full_name}が「#{project.name}」#{direction.directionmonth__c} 分業務指示内容の確認を完了しました。",
          OwnerId:         project.mws_gyomusekinin_sub_c__c,
          Priority:        '中',
          WhatId:          project.sfid,
          CompleteDate__c: Date.current.as_json
        }.stringify_keys
      end

      it do
        stub_salesforce_create_request('Task', task_params)
        direction.publish_approved_by_fc_task(sf_contact: sf_contact_fc)
      end
    end

    describe '#publish_rejected_by_fc_task' do
      let(:direction) { FactoryBot.create(:direction, trait, project:, directionmonth__c: '2020年10月', approveddatebyfc__c: Date.current) }
      let(:trait) { :waiting_for_fc }
      let(:task_params) do
        {
          Subject:      '[FC]業務指示内容の保留連絡',
          Status:       '完了',
          EigyoType__c: 'FCフォロー',
          ActivityDate: Date.current.as_json,
          Description:  "#{sf_contact_fc.full_name}から「#{project.name}」#{direction.directionmonth__c} 分業務内容の保留連絡がありました。FCからのコメントは業務責任者オブジェクトをご確認ください。",
          OwnerId:      project.mws_gyomusekinin_sub_c__c,
          Priority:     '中',
          WhatId:       project.sfid
        }.stringify_keys
      end

      it do
        stub_salesforce_create_request('Task', task_params)
        direction.publish_rejected_by_fc_task(sf_contact: sf_contact_fc)
      end
    end

    describe '#publish_auto_approved_by_fc_task' do
      let(:direction) { FactoryBot.create(:direction, trait, project:, directionmonth__c: '2020年10月', approveddatebyfc__c: Date.current) }
      let(:trait) { :waiting_for_fc }
      let(:task_params) do
        {
          Subject:         '[FC]業務指示内容の自動確認',
          Status:          '完了',
          EigyoType__c:    'FCフォロー',
          ActivityDate:    Date.current.as_json,
          Description:     "「#{project.name}」#{direction.directionmonth__c} 分の業務指示内容が自動確認されました。",
          OwnerId:         project.mws_gyomusekinin_sub_c__c,
          Priority:        '中',
          WhatId:          project.sfid,
          CompleteDate__c: Date.current.as_json
        }.stringify_keys
      end

      it do
        stub_salesforce_create_request('Task', task_params)
        direction.publish_auto_approved_by_fc_task(sf_contact: sf_contact_fc)
      end
    end
  end

  describe '#append_changed_histories' do
    context 'when changedhistories__c is empty' do
      let(:direction) { FactoryBot.build(:direction, changedhistories__c: nil) }

      it do
        expect(direction.append_changed_histories(kind: 'CL修正依頼', time: Time.zone.parse('2020-10-29 10:00'), description: 'Description')).to eq "[CL修正依頼：2020-10-29 10:00]\r\nDescription"
      end
    end

    context 'when changedhistories__c is not empty' do
      let(:direction) { FactoryBot.build(:direction, changedhistories__c: "CL修正依頼：2020-10-25 10:00\r\nDescription") }

      it do
        expect(direction.append_changed_histories(kind: 'CL修正依頼', time: Time.zone.parse('2020-10-29 10:00'), description: 'Description')).to eq "CL修正依頼：2020-10-25 10:00\r\nDescription\r\n\r\n[CL修正依頼：2020-10-29 10:00]\r\nDescription"
      end
    end
  end
end

# == Schema Information
#
# Table name: salesforce.direction__c
#
#  id                         :integer          not null, primary key
#  _hc_err                    :text
#  _hc_lastop                 :string(32)
#  approveddatebycl__c        :datetime
#  approveddatebyfc__c        :datetime
#  approverofcl__c            :string(255)
#  approveroffc__c            :string(255)
#  autoapprinterval_cl__c     :float
#  autoapprinterval_fc__c     :float
#  autoapproveddatetime_cl__c :datetime
#  autoapproveddatetime_fc__c :datetime
#  autoapprschedule_cl__c     :date
#  autoapprschedule_fc__c     :date
#  changedhistories__c        :text
#  commentfromfc__c           :text
#  createddate                :datetime
#  directiondetail__c         :text
#  directionmonth__c          :string(255)
#  directionmonthdate__c      :date
#  fc__c                      :string(18)
#  firstcheckdatebycl__c      :datetime
#  firstcheckdatebyfc__c      :datetime
#  isapprovedbycl__c          :boolean
#  isapprovedbyfc__c          :boolean
#  isdeleted                  :boolean
#  ismailqueue__c             :boolean
#  name                       :string(80)
#  newdirectiondetail__c      :text
#  opportunity__c             :string(18)
#  requestdatetime__c         :datetime
#  sfid                       :string(18)
#  status__c                  :string(255)
#  systemmodstamp             :datetime
#
# Indexes
#
#  hc_idx_direction__c_systemmodstamp  (systemmodstamp)
#  hcu_idx_direction__c_sfid           (sfid) UNIQUE
#
