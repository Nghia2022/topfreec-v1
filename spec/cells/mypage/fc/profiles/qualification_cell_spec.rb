# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Profiles::QualificationCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:licenses) { Faker::Lorem.paragraphs(number: 3) }

  context 'cell rendering' do
    describe 'rendering #show' do
      context 'when description is presence' do
        let(:model) { FactoryBot.build_stubbed(:contact, license__c: licenses.join("\n")).decorate }
        subject { described_cell.call(:show) }

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/profiles/qualification/show')
            .and licenses.map { |license| have_content(license) }.inject(:and)
        end
      end

      context 'when description is blank' do
        let(:model) { FactoryBot.build_stubbed(:contact, license__c: nil).decorate }
        subject { described_cell.call(:show) }

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/profiles/qualification/show')
            .and licenses.map { |license| have_no_content(license) }.inject(:and)
        end
      end
    end
  end
end
