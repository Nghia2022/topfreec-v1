# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Projects::RecommendedCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, projects, options) }
  let(:projects) { FactoryBot.build_stubbed_list(:project, 3).map(&:decorate) }
  let(:current_fc_profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_account_fc)) }

  before do
    allow(described_cell).to receive(:current_fc_profile).and_return(current_fc_profile)
  end

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      context 'when there are no projects' do
        let(:projects) { [] }

        it do
          is_expected.to have_no_content('おすすめの案件')
        end
      end

      context 'when there are projects' do
        let(:projects) { FactoryBot.build_stubbed_list(:project, 3).map(&:decorate) }
        let(:slick_options) do
          {
            slidesToShow:   2,
            slidesToScroll: 2
          }.to_json
        end

        it do
          is_expected.to have_content('おすすめの案件')
        end

        it do
          is_expected.to have_css "[data-slick='#{slick_options}']"
        end
      end
    end
  end
end
