# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::EditProfile::WorkHistoryForm, type: :model do
  describe 'validations' do
    subject { described_class.new }
    let(:status) { :unemployed }
    before do
      allow(subject).to receive(:status_unemployed?).and_return(status == :unemployed)
    end

    it do
      is_expected.to validate_presence_of(:company)
        .and validate_presence_of(:status)
        .and validate_presence_of(:joined)
    end

    context 'ステータスが現職中の場合' do
      let(:status) { :employed }

      it '退職年月は必須ではない' do
        is_expected.not_to validate_presence_of(:left)
      end
    end

    context 'ステータスが退職予定の場合' do
      let(:status) { :in_planning }

      it '退職年月は必須ではない' do
        is_expected.not_to validate_presence_of(:left)
      end
    end
  end

  shared_examples 'work_history_form preservation examples' do
    context 'with valid attributes' do
      let(:attributes) do
        {
          company:  Faker::Company.name,
          status:   WorkHistory.status__c.values.sample,
          joined:   '2019-04-01',
          left:     '2020-03-01',
          position: Faker::Job.position
        }
      end

      it 'should be return true and set persisted' do
        is_expected.to eq true
        expect(work_history_form).to be_persisted
      end

      it 'experience should be save' do
        subject
        expect(work_history.reload).to have_attributes(
          company_name__c: attributes[:company],
          status__c:       attributes[:status],
          start_date__c:   '2019-04-01'.to_date,
          end_date__c:     '2020-03-31'.to_date,
          position__c:     attributes[:position]
        )
      end
    end

    context 'with invalid attributes' do
      let(:attributes) do
        {
          left:   '2019-04-01',
          joined: '2020-03-01'
        }
      end

      it 'should be return false' do
        is_expected.to eq false
        expect(work_history_form).not_to be_persisted
      end
    end
  end

  describe '#save' do
    let(:work_history) { FactoryBot.create(:work_history) }
    let(:work_history_form) { described_class.new(attributes) }

    subject { work_history_form.save(work_history) }

    it_behaves_like 'work_history_form preservation examples'
  end

  describe '#update' do
    let(:work_history) { FactoryBot.create(:work_history) }
    let(:work_history_form) { described_class.new(attributes) }

    subject { work_history_form.update(work_history) }

    it_behaves_like 'work_history_form preservation examples'
  end
end
