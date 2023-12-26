# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FcUsers::MainRegistrations', type: :system do
  describe '本登録' do
    let(:fc_user) { FactoryBot.create(:fc_user) }
    let!(:contact) { FactoryBot.create(:contact, :fc, account:) }
    let(:account) { FactoryBot.create(:account_fc) }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc, 'Id' => contact.sfid) }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

    let(:new_password) { '#zH6eTaJbLuXjA1' }

    describe '本登録前にパスワードを設定する' do
      before do
        allow_any_instance_of(FcUser).to receive(:person).and_return(contact)
        allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
        allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)
        allow(Salesforce::Account).to receive(:find).and_return(sf_account)

        perform_enqueued_jobs do
          ActiveType.cast(fc_user, Fc::UserActivation::FcUser).send_activation(contact.sfid)
        end
      end

      it do
        open_email(fc_user.email)
        click_email_link_matching(/http/)

        expect(page.current_url).to eq new_mypage_fc_password_url

        fill_in 'fc_user[password]', with: new_password
        fill_in 'fc_user[password_confirmation]', with: new_password
        find('input[type="submit"]').click

        expect(page.current_url).to eq mypage_fc_registration_url
      end
    end
  end

  describe '本登録フォーム' do
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, registration_completed_at: nil) }
    let(:contact) { fc_user.contact }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
    let(:sf_account) { FactoryBot.build_stubbed(:sf_account_fc) }

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(sf_account)

      allow_any_instance_of(Restforce::Concerns::API).to receive(:update!).with('Contact', anything).and_return(true)

      contact.account.update(
        release_yotei__c: Date.current,
        kado_ritsu__c:    20
      )
      contact.update(
        work_prefecture1__c: Contact::WorkPrefecture1.all.first.value
      )
    end

    def find_checkbox(name, value)
      find(:css, "input[type='checkbox'][name='#{name}'][value='#{value}']")
    end

    describe 'checkboxes' do
      shared_examples_for 'choose checks and update' do
        it do
          sign_in(fc_user)
          visit mypage_fc_registration_path

          select('東京都', from: 'fc_user[prefecture]')
          fill_in('fc_user[city]', with: '渋谷区')
          fill_in('fc_user[zipcode]', with: '1234567')
          fill_in('fc_user[start_timing]', with: Date.current.to_s)
          fill_in('fc_user[reward_min]', with: 10)
          fill_in('fc_user[reward_desired]', with: 100)
          select('東京都23区内', from: 'fc_user[work_location1]')
          choose('週2日', name: 'fc_user[occupancy_rate]')

          chosen.each do |choise|
            find_checkbox(field_name, choise).check
          end

          click_on('会員登録する')

          contact.reload
          expect(contact.public_send(updated_column)).to eq chosen
        end
      end

      describe 'experienced_works' do
        let(:field_name) { 'fc_user[experienced_works][]' }
        let(:chosen) do
          Contact::ExperiencedWork.all.take(2).pluck(:value)
        end
        let(:updated_column) { :experienced_works__c }

        it_behaves_like 'choose checks and update'
      end
    end
  end
end
