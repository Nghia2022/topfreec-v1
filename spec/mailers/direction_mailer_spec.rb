# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DirectionMailer, type: :mailer do
  let(:project) { FactoryBot.create(:project, main_cl_contact:, sub_cl_contact:) }
  let(:direction) { ActiveType.cast(FactoryBot.build_stubbed(:direction, project:, directionmonth__c: '2020年10月'), Client::ManageDirection::Direction) }
  let(:main_cl_contact) { FactoryBot.create(:contact) }
  let(:sub_cl_contact) { FactoryBot.create(:contact) }
  let(:sf_main_cl_contact) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, Web_LoginEmail__c: 'main@client.com', LastName: '主', FirstName: '太郎', Kana_Sei__c: 'シュ', Kana_Mei__c: 'タロウ')) }
  let(:sf_sub_cl_contact) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, Web_LoginEmail__c: 'sub@client.com', LastName: '副', FirstName: '次郎', Kana_Sei__c: 'フク', Kana_Mei__c: 'ジロウ')) }
  let(:sf_main_fc_contact) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, Web_LoginEmail__c: 'main@fc.com', LastName: '主', FirstName: '太郎', Kana_Sei__c: 'シュ', Kana_Mei__c: 'タロウ')) }
  let(:sf_sub_fc_contact) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, Web_LoginEmail__c: 'sub@fc.com', LastName: '副', FirstName: '次郎', Kana_Sei__c: 'フク', Kana_Mei__c: 'ジロウ')) }
  let(:sf_account_fc) { FactoryBot.build_stubbed(:sf_account_fc) }
  let(:main_mws_user) { Salesforce::User.new(FactoryBot.build_stubbed(:sf_user, Email: 'main@mws.com')) }
  let(:sub_mws_user) { Salesforce::User.new(FactoryBot.build_stubbed(:sf_user, Email: 'sub@mws.com')) }

  let(:client_presenter) do
    Client::ManageDirection::DirectionMailerPresenterBuilder.new(direction).tap do |builder|
      allow(builder).to receive(:main_cl_contact).and_return(sf_main_cl_contact)
      allow(builder).to receive(:sub_cl_contact).and_return(sf_sub_cl_contact)
      allow(builder).to receive(:fc_account).and_return(sf_account_fc)
      allow(builder).to receive(:main_mws_user).and_return(main_mws_user)
      allow(builder).to receive(:sub_mws_user).and_return(sub_mws_user)
    end
  end
  let(:fc_presenter) do
    Fc::ManageDirection::DirectionMailerPresenterBuilder.new(direction).tap do |builder|
      allow(builder).to receive(:main_fc_contact).and_return(sf_main_fc_contact)
      allow(builder).to receive(:sub_fc_contact).and_return(sf_sub_fc_contact)
      allow(builder).to receive(:fc_account).and_return(sf_account_fc)
      allow(builder).to receive(:main_mws_user).and_return(main_mws_user)
      allow(builder).to receive(:sub_mws_user).and_return(sub_mws_user)
    end
  end

  shared_examples 'receive message for client' do
    before do
      allow(Client::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(client_presenter)
    end

    it do
      expect(email)
        .to have_subject(email_subject)
        .and deliver_from(sub_mws_user.email)
        .and deliver_to(sf_main_cl_contact.web_login_email)
        .and cc_to(sf_sub_cl_contact.web_login_email, main_mws_user.email, sub_mws_user.email)
        .and bcc_to(Settings.mailer.direction.bcc)
    end

    context 'when main client and sub client are not the same' do
      it do
        expect(email.body.encoded)
          .to have_content('主 太郎 様', count: 1)
          .and have_content('(CC：副 次郎 様)', count: 1)
      end

      it do
        expect(email)
          .to cc_to(sf_sub_cl_contact.web_login_email, main_mws_user.email, sub_mws_user.email)
      end
    end

    context 'when main client and sub client are the same' do
      let(:sf_sub_cl_contact) { sf_main_cl_contact }

      it do
        expect(email.body.encoded)
          .to have_content('主 太郎 様', count: 1)
          .and have_content('(CC：副 次郎 様)', count: 0)
      end

      it do
        expect(email)
          .to cc_to(main_mws_user.email, sub_mws_user.email)
      end
    end

    context 'when sub client is not present' do
      let(:sf_sub_cl_contact) { Salesforce::Contact.null }

      it do
        expect(email.body.encoded)
          .to have_content('主 太郎 様', count: 1)
          .and have_content('(CC：副 次郎 様)', count: 0)
      end
    end

    context 'when main and sub mws user are same' do
      let(:sub_mws_user) { main_mws_user }

      it do
        expect(email)
          .to have_subject(email_subject)
          .and deliver_from(sub_mws_user.email)
          .and deliver_to(sf_main_cl_contact.web_login_email)
          .and cc_to(sf_sub_cl_contact.web_login_email, main_mws_user.email)
          .and bcc_to(Settings.mailer.direction.bcc)
      end
    end
  end

  shared_examples 'receive message for fc' do
    before do
      allow(Fc::ManageDirection::DirectionMailerPresenterBuilder).to receive(:new).and_return(fc_presenter)
    end

    it do
      expect(email)
        .to have_subject(email_subject)
        .and deliver_from(sub_mws_user.email)
        .and deliver_to(sf_main_fc_contact.web_login_email)
        .and deliver_to(sf_main_fc_contact.web_login_email)
        .and cc_to(sf_sub_fc_contact.web_login_email, main_mws_user.email, sub_mws_user.email)
        .and bcc_to(Settings.mailer.direction.bcc)
    end

    context 'when main fc and sub fc are not the same' do
      it do
        expect(email.body.encoded)
          .to have_content('主 太郎 様', count: 1)
          .and have_content('(CC：副 次郎 様)', count: 1)
      end
    end

    context 'when main fc and sub fc are the same' do
      let(:sf_sub_fc_contact) { sf_main_fc_contact }

      it do
        expect(email.body.encoded)
          .to have_content('主 太郎 様', count: 1)
          .and have_content('(CC：副 次郎 様)', count: 0)
      end
    end

    context 'when sub fc is not present' do
      let(:sf_sub_fc_contact) { Salesforce::Contact.null }

      it do
        expect(email.body.encoded)
          .to have_content('主 太郎 様', count: 1)
          .and have_content('(CC：副 次郎 様)', count: 0)
      end
    end

    context 'when main and sub mws user are same' do
      let(:sub_mws_user) { main_mws_user }

      it do
        expect(email)
          .to have_subject(email_subject)
          .and deliver_from(sub_mws_user.email)
          .and deliver_to(sf_main_fc_contact.web_login_email)
          .and cc_to(sf_sub_fc_contact.web_login_email, main_mws_user.email)
          .and bcc_to(Settings.mailer.direction.bcc)
      end
    end
  end

  describe '#notify_confirmation_request_to_client' do
    let(:email) { DirectionMailer.notify_confirmation_request_to_client(direction) }

    it_behaves_like 'receive message for client' do
      let(:email_subject) { '【みらいワークス】業務指示内容確認のお願い' }
    end
  end

  describe '#notify_auto_approved_by_client' do
    let(:email) { DirectionMailer.notify_auto_approved_by_client(direction) }

    it_behaves_like 'receive message for client' do
      let(:email_subject) { '【みらいワークス】業務指示内容確認完了ご通知' }
    end
  end

  describe '#notify_modification_request_to_client' do
    let(:email) { DirectionMailer.notify_modification_request_to_client(direction, authorizer_of_client_full_name: sf_main_cl_contact.Name) }

    it_behaves_like 'receive message for client' do
      let(:email_subject) { '【みらいワークス】修正業務指示内容のご確認' }
    end
  end

  describe '#notify_confirmation_completed_to_client' do
    let(:email) { DirectionMailer.notify_confirmation_completed_to_client(direction) }

    it_behaves_like 'receive message for client' do
      let(:email_subject) { '【みらいワークス】業務指示内容確認完了案内' }
    end
  end

  describe '#notify_confirmation_request_to_fc' do
    let(:email) { DirectionMailer.notify_confirmation_request_to_fc(direction) }

    it_behaves_like 'receive message for fc' do
      let(:email_subject) { '【みらいワークス】業務指示内容確認のお願い' }
    end
  end

  describe '#notify_reconfirmation_request_to_client' do
    let(:email) { DirectionMailer.notify_reconfirmation_request_to_client(direction) }

    it_behaves_like 'receive message for client' do
      let(:email_subject) { '【みらいワークス】業務指示内容確認のお願い（修正版)' }
    end
  end

  describe '#notify_confirmation_completed_to_fc' do
    let(:email) { DirectionMailer.notify_confirmation_completed_to_fc(direction) }

    it_behaves_like 'receive message for fc' do
      let(:email_subject) { '【みらいワークス】業務指示内容確認完了案内' }
    end
  end

  describe '#notify_modification_request_to_fc' do
    let(:email) { DirectionMailer.notify_modification_request_to_fc(direction, modification_requester_of_fc_full_name: sf_main_fc_contact.Name) }

    it_behaves_like 'receive message for fc' do
      let(:email_subject) { '【みらいワークス】修正業務指示内容のご確認' }
    end
  end

  describe '#notify_auto_approved_by_fc' do
    let(:email) { DirectionMailer.notify_auto_approved_by_fc(direction) }

    it_behaves_like 'receive message for fc' do
      let(:email_subject) { '【みらいワークス】業務指示内容確認完了ご通知' }
    end
  end
end
