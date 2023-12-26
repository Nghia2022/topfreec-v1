# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::MainRegistration::RegistrationForm, type: :model do
  describe 'validations' do
    let(:form) { described_class.new }
    subject { form }

    it do
      is_expected.to validate_presence_of(:zipcode)
        .and validate_presence_of(:prefecture)
        .and validate_presence_of(:city)
        .and validate_presence_of(:start_timing)
        .and validate_numericality_of(:reward_min).is_less_than(1000).only_integer
        .and validate_presence_of(:occupancy_rate)
        .and validate_length_of(:requests).is_at_most(1200)
    end

    it_behaves_like 'validate_zipcode', :zipcode

    describe '#reward_min' do
      it do
        is_expected.to allow_value(0, 123, 999).for(:reward_min)
          .and not_allow_value(-1).for(:reward_min)
          .and not_allow_value(1000).for(:reward_min)
          .and not_allow_value('a').for(:reward_min)
      end
    end

    describe '#reward_desired' do
      it do
        is_expected.to allow_value(0, 123, 999).for(:reward_min)
          .and not_allow_value(-1).for(:reward_min)
          .and not_allow_value(1000).for(:reward_min)
          .and not_allow_value('a').for(:reward_min)
      end
    end

    describe '#start_timing' do
      it do
        is_expected.to validate_presence_of(:start_timing)
      end

      context 'invalid' do
        subject { described_class.new(start_timing: 1.day.ago) }
        it do
          subject.valid?
          expect(subject.errors[:start_timing]).to include('は現在より未来の日付を選択してください')
        end
      end
    end

    describe '#work_location1' do
      it do
        is_expected.to validate_presence_of(:work_location1)
      end
    end

    describe '#work_location2' do
      context 'when work_location1 is blank' do
        before do
          form.work_location1 = nil
          form.work_location2 = Project::WorkPrefecture.all.sample.value
        end

        it do
          is_expected
            .to validate_absence_of(:work_location2)
        end
      end
    end

    describe '#work_location3' do
      context 'when work_location2 is blank' do
        before do
          form.work_location1 = Project::WorkPrefecture.all.sample.value
          form.work_location2 = nil
          form.work_location3 = Project::WorkPrefecture.all.sample.value
        end

        it do
          is_expected
            .to validate_absence_of(:work_location3)
        end
      end
    end

    describe '#experienced_works_sub' do
      context 'when the feature flag :new_work_category is true' do
        # TODO: #3353 :beforeの削除
        before do
          Flipper.enable :new_work_category
        end

        let(:attributes) { { experienced_works_sub: WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4)) } }
        it do
          is_expected
            .to validate_inclusion_of(:experienced_works_sub).in_array(attributes[:experienced_works_sub])
        end

        describe 'length' do
          it do
            is_expected.to allow_value(WorkCategory.pluck(:sub_category).flatten.sample(100)).for(:experienced_works_sub)
              .and not_allow_value(WorkCategory.pluck(:sub_category).flatten.sample(101)).for(:experienced_works_sub).with_message('選択できる得意領域数は100件を上限としております。')
          end
        end
      end
    end

    describe '#desired_works_sub' do
      context 'when the feature flag :new_work_category is true' do
        # TODO: #3353 :beforeの削除
        before do
          Flipper.enable :new_work_category
        end

        let(:attributes) { { desired_works_sub: WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4)) } }
        it do
          is_expected
            .to validate_inclusion_of(:desired_works_sub).in_array(attributes[:desired_works_sub])
        end

        describe 'length' do
          it do
            is_expected.to allow_value(WorkCategory.pluck(:sub_category).flatten.sample(100)).for(:desired_works_sub)
              .and not_allow_value(WorkCategory.pluck(:sub_category).flatten.sample(101)).for(:desired_works_sub).with_message('選択できる希望領域数は100件を上限としております。')
          end
        end
      end
    end
  end

  describe '#save' do
    let(:form) { described_class.new }
    let(:fc_user) { FactoryBot.create(:fc_user, :activated, contact_trait:) }
    let(:contact_trait) { [] }
    let(:contact) { fc_user.contact }
    let(:account) { contact.account }
    let(:valid_params) do
      {
        zipcode:        '1234567',
        prefecture:     JpPrefecture::Prefecture.all.sample.name,
        city:           Faker::Address.street_address,
        start_timing:   Date.current,
        work_location1: Contact::WorkPrefecture1.all.map(&:value).sample,
        business_form:  Contact::WorkOption.all.map(&:value).sample(rand(1..4)),
        occupancy_rate: 80,
        requests:       "memo\nmemo",
        reward_min:     10,
        reward_desired: 20
      }
    end
    let(:params) { valid_params }

    before do
      stub_salesforce_request
      form.assign_attributes(params)
    end

    context 'when form is valid' do
      shared_examples 'save record' do
        it do
          expect do
            form.save(fc_user)
          end.to change(form, :persisted).from(false).to(true)
            .and change { contact.reload.work_prefecture1__c }
            .and change { contact.fcweb_kibou_memo__c }
            .and change { account.reload.kado_ritsu__c }.from(nil).to(80.0)
            .and change(account, :release_yotei_kakudo__c).to('確定')
            .and change(account, :release_yotei__c).to(release_yotei__c)
            .and change(account, :saitei_hosyu__c).to(valid_params[:reward_min])
            .and change(account, :kibo_hosyu__c).to(valid_params[:reward_desired])
        end
      end

      context 'when adjust_start_timing is disabled' do
        let(:release_yotei__c) { valid_params[:start_timing].to_date }

        include_examples 'save record'
      end

      context 'when adjust_start_timing is enabled' do
        let(:release_yotei__c) { 1.day.ago(valid_params[:start_timing].to_date) }

        before do
          FeatureSwitch.enable :adjust_start_timing
        end

        include_examples 'save record'
      end

      context 'when start_timing and reward_desired are not changed' do
        let(:contact_trait) { :valid_data_for_register }
        let(:params) do
          { **valid_params, start_timing: account.release_yotei__c, reward_desired: account.kibo_hosyu__c }
        end

        it do
          expect do
            form.save(fc_user)
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
            form.save(fc_user)
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
            form.save(fc_user)
          end.to(change { account.reload.kakunin_bi__c }.from(nil).to(Date.current))
        end
      end

      context 'when experienced_works_sub is changed' do
        let(:contact_trait) { :valid_data_for_register }
        let(:experienced_works_sub) { WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4)) }
        let(:experienced_works_main) { WorkCategory.group_sub_categories(experienced_works_sub).keys }
        let(:params) do
          { **valid_params, experienced_works_sub: }
        end

        it do
          expect do
            form.save(fc_user)
          end.to change { contact.reload.experienced_works_sub__c }.from(%w[IT・PM IT・PMO 事業開発（企画）]).to(experienced_works_sub)
            .and change { contact.experienced_works_main__c }.from(%w[ITプロジェクト管理 新規事業]).to(experienced_works_main)
        end
      end

      context 'when desired_works_sub is changed' do
        let(:contact_trait) { :valid_data_for_register }
        let(:desired_works_sub) { WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4)) }
        let(:desired_works_main) { WorkCategory.group_sub_categories(desired_works_sub).keys }
        let(:params) do
          { **valid_params, desired_works_sub: }
        end

        it do
          expect do
            form.save(fc_user)
          end.to change { contact.reload.desired_works_sub__c }.from(%w[IT・PM IT・PMO 事業開発（企画）]).to(desired_works_sub)
            .and change { contact.desired_works_main__c }.from(%w[ITプロジェクト管理 新規事業]).to(desired_works_main)
        end
      end
    end

    context 'when store_profile is invalid' do
      before do
        allow_any_instance_of(Fc::MainRegistration::Profile).to receive(:save).and_raise(Restforce::AuthenticationError)
      end

      it do
        expect do
          form.save(fc_user)
        end.to raise_error(Restforce::AuthenticationError)
          .and not_change(form, :persisted)
          .and(not_change { contact.reload.work_prefecture1__c })
          .and(not_change { account.reload.kado_ritsu__c })
          .and(not_change { fc_user.reload.registration_completed_at })
      end
    end
  end
end
