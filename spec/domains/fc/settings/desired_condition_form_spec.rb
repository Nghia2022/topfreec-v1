# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::Settings::DesiredConditionForm, type: :model do
  describe 'validations' do
    let(:attributes) { {} }
    subject { described_class.new(attributes) }

    describe '#work_location1' do
      it do
        is_expected.to validate_presence_of(:work_location1)
      end
    end

    describe '#work_location2' do
      context 'when work_location1 is blank' do
        let(:attributes) do
          {
            work_location1: nil,
            work_location2: Project::WorkPrefecture.all.sample.value,
            work_location3: Project::WorkPrefecture.all.sample.value
          }
        end

        it do
          is_expected
            .to validate_absence_of(:work_location2)
        end
      end
    end

    describe '#work_location3' do
      context 'when work_location2 is blank' do
        let(:attributes) do
          {
            work_location1: Project::WorkPrefecture.all.sample.value,
            work_location2: nil,
            work_location3: Project::WorkPrefecture.all.sample.value
          }
        end

        it do
          is_expected
            .to validate_absence_of(:work_location3)
        end
      end
    end
  end

  describe '#contact_attributes' do
    where(:key, :value, :expected) do
      described_class::ARRAY_ATTRIBUTES.map do |attr|
        [
          [[], []],
          [[''], []],
          [%w[test], %w[test]]
        ].map { |values| [attr, *values] }
      end.inject(:+)
    end

    with_them do
      let(:form) { described_class.new(key => value) }

      it do
        expect(form.send(:contact_attributes)[key]).to eq(expected)
      end
    end
  end
end
