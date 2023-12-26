# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  it_behaves_like 'sobject', 'Contact'

  describe 'associations' do
    it { is_expected.to belong_to(:account).with_foreign_key(:accountid).with_primary_key(:sfid).optional }
    it { is_expected.to have_one(:client_user).with_foreign_key(:contact_sfid).with_primary_key(:sfid) }
    it { is_expected.to have_many(:experiences).with_foreign_key(:who__c).with_primary_key(:sfid) }
    it { is_expected.to have_many(:work_histories).with_foreign_key(:person__c).with_primary_key(:sfid) }
  end

  describe 'triggers' do
    describe 'change email' do
      let(:new_email) { Faker::Internet.email }

      shared_examples 'update FcUser#email' do
        it do
          expect do
            contact.update(web_loginemail__c: new_email)
            fc_user.reload
          end.to change(fc_user, :email).to(new_email)
        end
      end

      shared_examples "can't update FcUser#email" do
        it do
          expect do
            contact.update(web_loginemail__c: new_email)
          end.to raise_error(ActiveRecord::RecordNotUnique)
            .and not_change(fc_user, :email).from(contact.web_loginemail__c)
        end
      end

      context 'when contact is fc' do
        let!(:fc_user) { FactoryBot.create(:fc_user, :activated, contact:, email: contact.email) }
        let!(:contact) { FactoryBot.create(:contact, :fc) }
        let(:new_email) { Faker::Internet.email }

        it_behaves_like 'update FcUser#email'

        context 'when changed email to existing' do
          let!(:existing_fc_user) { FactoryBot.create(:fc_user, :activated, contact: existing_contact, email: existing_contact.email) }
          let!(:existing_contact) { FactoryBot.create(:contact, :fc) }
          let(:new_email) { existing_contact.email }

          it_behaves_like "can't update FcUser#email"
        end
      end

      context 'when contact is fc_company' do
        let!(:fc_user) { FactoryBot.create(:fc_user, :activated, contact:, email: contact.email) }
        let!(:contact) { FactoryBot.create(:contact, :fc_company) }
        let(:new_email) { Faker::Internet.email }

        it_behaves_like 'update FcUser#email'

        context 'when changed email to existing' do
          let!(:existing_fc_user) { FactoryBot.create(:fc_user, :activated, contact: existing_contact, email: existing_contact.email) }
          let!(:existing_contact) { FactoryBot.create(:contact, :fc_company) }
          let(:new_email) { existing_contact.email }

          it_behaves_like "can't update FcUser#email"
        end
      end

      context 'when contact is client' do
        let!(:client_user) { FactoryBot.create(:client_user, contact:, email: contact.email) }
        let!(:contact) { FactoryBot.create(:contact, :client) }

        it do
          expect do
            contact.update(web_loginemail__c: new_email)
            client_user.reload
          end.to change(client_user, :email).to(new_email)
        end

        context 'when changed email to existing' do
          let!(:existing_client_user) { FactoryBot.create(:client_user, contact: existing_contact, email: existing_contact.web_loginemail__c) }
          let!(:existing_contact) { FactoryBot.create(:contact, :client) }
          let(:new_email) { existing_contact.email }

          it do
            expect do
              contact.update(web_loginemail__c: new_email)
            end.to raise_error(ActiveRecord::RecordNotUnique)
              .and not_change(client_user, :email).from(contact.web_loginemail__c)
          end
        end
      end
    end
  end

  describe '#sign_in_allowed_fc?' do
    subject { contact.sign_in_allowed_fc? }

    context 'when account is released' do
      let!(:contact) { FactoryBot.create(:contact, :fc) }

      it { is_expected.to eq true }
    end

    context 'when account is not released' do
      let(:contact) { FactoryBot.create(:contact, :fc, account_fc_trait: [:unreleased]) }

      context 'without main and sub fc contact' do
        it { is_expected.to eq false }
      end

      context 'with main fc contact' do
        let!(:project) { FactoryBot.create(:project, main_fc_contact: contact) }

        it { is_expected.to eq true }
      end

      context 'with sub fc contact' do
        let!(:project) { FactoryBot.create(:project, sub_fc_contact: contact) }

        it { is_expected.to eq true }
      end
    end
  end

  describe '#arranged_experiences_work_categories' do
    subject { contact.arranged_experiences_work_categories }

    let(:contact) { FactoryBot.create(:contact, :fc, :valid_data_for_register) }

    it 'have called WorkCategory.arranged_categories' do
      allow(WorkCategory).to receive(:group_sub_categories)
      subject
      expect(WorkCategory).to have_received(:group_sub_categories).once
    end
  end

  describe '#arranged_desired_work_categories' do
    subject { contact.arranged_desired_work_categories }

    let(:contact) { FactoryBot.create(:contact, :fc, :valid_data_for_register) }

    it 'have called WorkCategory.arranged_categories' do
      allow(WorkCategory).to receive(:group_sub_categories)
      subject
      expect(WorkCategory).to have_received(:group_sub_categories).once
    end
  end

  describe '#save_commmune_login_datetime' do
    subject(:perform) { contact.save_commmune_login_datetime }

    let(:commmune_firstlogindatetime__c) { nil }
    let(:commmune_lastlogindatetime__c) { nil }
    let(:contact) do
      FactoryBot.create(:contact, :fc, :valid_data_for_register,
                        commmune_firstlogindatetime__c:,
                        commmune_lastlogindatetime__c:  commmune_firstlogindatetime__c)
    end

    before do
      freeze_time
    end

    context 'when commmune_firstlogindatetime__c is nil' do
      let(:commmune_firstlogindatetime__c) { nil }
      let(:commmune_lastlogindatetime__c) { nil }

      it do
        expect do
          perform
        end.to [
          change(contact, :commmune_firstlogindatetime__c).from(nil).to(Time.current),
          change(contact, :commmune_lastlogindatetime__c).from(nil).to(Time.current)
        ].inject(:and)
      end
    end

    context 'when commmune_firstlogindatetime__c is not nil' do
      let(:commmune_firstlogindatetime__c) { 1.day.ago }
      let(:commmune_lastlogindatetime__c) { 1.day.ago }

      it do
        expect do
          perform
        end.to [
          not_change(contact, :commmune_firstlogindatetime__c).from(commmune_firstlogindatetime__c),
          change(contact, :commmune_lastlogindatetime__c).from(commmune_lastlogindatetime__c).to(Time.current)
        ].inject(:and)
      end
    end
  end
end

# == Schema Information
#
# Table name: salesforce.contact
#
#  id                             :integer          not null, primary key
#  _hc_err                        :text
#  _hc_lastop                     :string(32)
#  accountid                      :string(18)
#  commmune_firstlogindatetime__c :datetime
#  commmune_lastlogindatetime__c  :datetime
#  createddate                    :datetime
#  desired_works__c               :string(4099)
#  desired_works_main__c          :string(4099)
#  desired_works_sub__c           :string(4099)
#  email                          :string(80)
#  existsinheroku__c              :boolean
#  experienced_company_size__c    :string(4099)
#  experienced_works__c           :string(4099)
#  experienced_works_main__c      :string(4099)
#  experienced_works_sub__c       :string(4099)
#  fcweb_kibou_memo__c            :string(1200)
#  fcweb_logindatetime__c         :datetime
#  isdeleted                      :boolean
#  license__c                     :string(500)
#  ml_reject__c                   :boolean
#  recordtypename__c              :string(1300)
#  sfid                           :string(18)
#  systemmodstamp                 :datetime
#  web_loginemail__c              :string(80)
#  work_options__c                :string(4099)
#  work_prefecture1__c            :string(255)
#  work_prefecture2__c            :string(255)
#  work_prefecture3__c            :string(255)
#
# Indexes
#
#  hc_idx_contact_accountid          (accountid)
#  hc_idx_contact_systemmodstamp     (systemmodstamp)
#  hc_idx_contact_web_loginemail__c  (web_loginemail__c)
#  hcu_idx_contact_sfid              (sfid) UNIQUE
#
