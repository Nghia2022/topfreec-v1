# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::EditExperience::ExperienceForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:members_num) }
    it { is_expected.to validate_numericality_of(:members_num).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:role) }
  end

  shared_examples 'experience_form preservation examples' do
    context 'with valid attributes' do
      let(:attributes) do
        {
          name:        Faker::Company.name,
          description: Faker::Lorem.paragraphs(number: rand(3..7)).join("\n"),
          members_num: 3,
          role:        Faker::Lorem.paragraphs(number: rand(3..7)).join("\n"),
          joined:      '2019-04-01',
          left:        '2020-03-01'
        }
      end

      it 'should be return true and set persisted' do
        is_expected.to eq true
        expect(experience_form).to be_persisted
      end

      it 'experience should be save' do
        subject
        expect(experience.reload).to have_attributes(
          name:             attributes[:name],
          details_self__c:  attributes[:description],
          member_amount__c: 3.0,
          position__c:      attributes[:role],
          start_date__c:    '2019-04-01'.to_date,
          end_date__c:      '2020-03-31'.to_date
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
        expect(experience_form).not_to be_persisted
      end
    end
  end

  describe '#save' do
    let(:experience) { FactoryBot.build(:experience) }
    let(:experience_form) { described_class.new.tap { |this| this.assign_attributes(attributes) } }

    subject { experience_form.save(experience) }

    it_behaves_like 'experience_form preservation examples'
  end

  describe '#update' do
    let(:experience) { FactoryBot.create(:experience) }
    let(:experience_form) { described_class.new.tap { |this| this.assign_attributes(attributes) } }

    subject { experience_form.update(experience) }

    it_behaves_like 'experience_form preservation examples'
  end
end
