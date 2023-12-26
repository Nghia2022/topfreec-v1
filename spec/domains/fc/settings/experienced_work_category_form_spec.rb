# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::Settings::ExperiencedWorkCategoryForm, type: :model do
  describe 'validations' do
    subject { described_class.new(attributes) }

    describe '#experienced_works_sub' do
      let(:attributes) { { experienced_works_sub: WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4)) } }
      it do
        is_expected
          .to validate_inclusion_of(:experienced_works_sub).in_array(attributes[:experienced_works_sub])
      end

      describe 'length' do
        it do
          is_expected.to allow_value(WorkCategory.pluck(:sub_category).flatten.sample(100)).for(:experienced_works_sub)
            .and not_allow_value(WorkCategory.pluck(:sub_category).flatten.sample(101)).for(:experienced_works_sub).with_message('選択できる領域数は100件を上限としております。')
        end
      end
    end

    describe '#save' do
      let(:form) { described_class.new }
      let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
      let!(:person) { fc_user.person }
      let!(:contact) { fc_user.contact }
      let(:params) { valid_params }
      let(:valid_params) do
        {
          experienced_works_sub:
        }
      end
      let(:experienced_works_main) { WorkCategory.group_sub_categories(experienced_works_sub).keys }
      let(:experienced_works_sub) { WorkCategory.pluck(:sub_category).flatten.sample(rand(1..4)) }

      before do
        stub_salesforce_request
        form.assign_attributes(params)
      end

      context 'with valid' do
        it do
          expect do
            form.save(person)
          end.to change { contact.reload.experienced_works_sub__c }.to(experienced_works_sub)
            .and change { contact.reload.experienced_works_main__c }.to(experienced_works_main)
        end
      end

      context 'with invalid' do
        let(:params) do
          {
            experienced_works_sub: experienced_works_sub.push('テスト')
          }
        end

        it do
          expect do
            form.save(person)
          end.to not_change(contact, :experienced_works_sub__c)
            .and not_change(contact, :experienced_works_main__c)
        end

        it 'changed attribute of experienced_works_main' do
          form.save(person)
          expect(form.experienced_works_main).to eq(experienced_works_main)
        end
      end
    end
  end
end
