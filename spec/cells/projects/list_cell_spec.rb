# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ListCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { ProjectDecorator.decorate_collection(projects) }
  let(:projects) { FactoryBot.build_stubbed_list(:project, 2) }
  let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :activated) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      before do
        allow(controller).to receive(:current_user).and_return(fc_user)
        allow_any_instance_of(Devise::Controllers::Helpers).to receive(:current_fc_user).and_return(model)
      end

      it do
        is_expected.to model.map { |project| have_content(project.project_name) }.inject(:and)
      end
    end

    describe 'rendering without image_index' do
      subject { described_cell.call(:show) }
      let(:projects) do
        FactoryBot.build_stubbed_list(:project, 5, experiencecatergory__c: ['PM/PMO']) + [FactoryBot.build_stubbed(:project, experiencecatergory__c: ['IT PM/PMO'])]
      end

      before do
        allow(controller).to receive(:current_user).and_return(fc_user)
        allow_any_instance_of(Devise::Controllers::Helpers).to receive(:current_fc_user).and_return(model)
      end

      it do
        is_expected.to model
          .map { |record|
            have_content(record.project_name)
            .and have_content('PM/PMO')
          }
          .inject(:and)
      end

      it do
        is_expected.to have_no_selector("img[src='#{model.first.category_image(5)}']")
      end
    end
  end
end
