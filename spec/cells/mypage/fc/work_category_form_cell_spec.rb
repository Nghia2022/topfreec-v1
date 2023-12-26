# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::WorkCategoryFormCell, type: :cell do
  controller ApplicationController

  let(:works_main) { WorkCategory.pluck(:main_category).flatten.sample(rand(1..4)) }
  let(:described_cell) { cell(described_class, nil, selected_main_categories: works_main) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show, &:main_category) }

      it do
        is_expected.to have_selector(:testid, 'mypage/fc/work_category_form/show')
      end

      it do
        is_expected.to have_content(works_main.first)
      end
    end
  end
end
