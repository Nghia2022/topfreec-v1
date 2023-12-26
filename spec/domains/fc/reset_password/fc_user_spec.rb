# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::ResetPassword::FcUser, type: :model do
  describe '.find_first_by_auth_conditions' do
    let(:attributes) do
      {
        email: contact.web_loginemail__c
      }
    end

    subject do
      Fc::ResetPassword::FcUser.find_first_by_auth_conditions(attributes)
    end

    context 'when user is exists' do
      let!(:contact) { FactoryBot.create(:contact, :fc) }
      let!(:fc_user) { ActiveType.cast(FactoryBot.create(:fc_user, email: contact.web_loginemail__c, contact:), Fc::ResetPassword::FcUser) }

      it do
        expect do
          subject
        end.to not_change(Fc::ResetPassword::FcUser, :count)
      end

      context 'when account is released' do
        it do
          is_expected.to eq(fc_user)
        end
      end

      context 'when account is not released' do
        let!(:contact) { FactoryBot.create(:contact, :fc, account_fc_trait: [:unreleased]) }

        it do
          is_expected.to eq(nil)
        end
      end
    end

    context 'when user is not exists' do
      shared_examples 'does not create fc user' do
        it do
          expect do
            subject
          end.to not_change(Fc::ResetPassword::FcUser, :count)
        end

        it do
          is_expected.to eq(nil)
        end
      end

      context 'when contact is exists' do
        let(:now) { Time.zone.parse('2020-10-01 00:00:00') }

        around do |ex|
          travel_to(now) { ex.run }
        end

        shared_examples 'create fc user' do
          it do
            expect do
              subject
            end.to change(Fc::ResetPassword::FcUser, :count).by(1)
          end

          it do
            is_expected
              .to have_attributes(
                email:        contact.web_loginemail__c,
                contact_sfid: contact.sfid,
                confirmed_at: now,
                activated_at: now
              )
          end
        end

        context 'when account is released' do
          context 'when contact is fc' do
            let!(:contact) { FactoryBot.create(:contact, :fc) }

            it_behaves_like 'create fc user'
          end

          context 'when contact is fc' do
            let!(:contact) { FactoryBot.create(:contact, :fc_company) }

            it_behaves_like 'create fc user'
          end
        end

        context 'when account is not released' do
          let!(:contact) { FactoryBot.create(:contact, :fc, account_fc_trait: [:unreleased]) }

          context 'when contact is main fc of project' do
            let!(:project) { FactoryBot.create(:project, main_fc_contact: contact) }

            it_behaves_like 'create fc user'
          end

          context 'when contact is sub fc of project' do
            let!(:project) { FactoryBot.create(:project, sub_fc_contact: contact) }

            it_behaves_like 'create fc user'
          end

          context 'when account is not main/sub fc of project' do
            it_behaves_like 'does not create fc user'
          end
        end
      end

      context 'when contact is not exists' do
        let(:contact) { FactoryBot.build(:contact, :fc) }

        it_behaves_like 'does not create fc user'
      end
    end
  end

  describe '.reset_password_by_token' do
    let!(:fc_user) { ActiveType.cast(FactoryBot.create(:fc_user, fc_user_trait, contact:), Fc::ResetPassword::FcUser) }
    let(:contact) { FactoryBot.build(:contact, :fc) }
    let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }

    before do
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
    end

    subject(:perform) do
      token = fc_user.send_reset_password_instructions
      fc_user.class.reset_password_by_token(
        reset_password_token:  token,
        password:              '#zH6eTaJbLuXjA1',
        password_confirmation: '#zH6eTaJbLuXjA1'
      )
      fc_user
    end

    context 'when user is not activated' do
      let(:fc_user_trait) { :unconfirmed }

      it do
        expect do
          perform
        end.to change { fc_user.reload.activated? }.from(false).to(true)
      end
    end

    context 'when user is activated' do
      let(:fc_user_trait) { :activated }

      it do
        expect do
          perform
        end.not_to(change { fc_user.reload.activated_at })
      end
    end
  end
end
