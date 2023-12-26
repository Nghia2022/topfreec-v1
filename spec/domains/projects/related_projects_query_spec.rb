# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::RelatedProjectsQuery, type: :model do
  let(:model) { described_class.new(relation:, project:, display_limit: 10) }
  let(:relation) { Project.where.not(sfid: project.sfid) }
  let(:project) do
    FactoryBot.build_stubbed(
      :project,
      experiencecatergory__c: [Project::ExperienceCategory.pick(:value)]
    ).decorate
  end

  let!(:project_match) { FactoryBot.create(:project, experiencecatergory__c: [Project::ExperienceCategory.pick(:value)]) }
  let!(:project_not_match) { FactoryBot.create(:project) }

  describe '#call' do
    context 'when selected_projects_with_all_less_than_display_limit? is true' do
      it do
        expect(model.call).to eq(model.selected_projects_with_any)
      end
    end

    context 'when selected_projects_with_all_less_than_display_limit? is false' do
      let(:model) { described_class.new(relation:, project:, display_limit: 1) }

      it do
        expect(model.call).to eq(model.selected_projects_with_all)
      end
    end
  end

  describe '#selected_projects_with_all' do
    it do
      expect(model.selected_projects_with_all)
        .to include(project_match)
        .and not_include(project_not_match)
    end
  end

  describe '#selected_projects_with_any' do
    context 'when project has categories' do
      it do
        expect(model.selected_projects_with_any)
          .to include(project_match)
          .and not_include(project_not_match)
      end
    end

    context 'when project has no categories' do
      let(:project) { FactoryBot.build_stubbed(:project).decorate }
      it do
        expect(model.selected_projects_with_any)
          .to include(project_match, project_not_match)
      end
    end
  end
end
