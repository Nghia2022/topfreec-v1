# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::Recommended::ProjectsQuery, type: :model do
  let(:model) { described_class.new(relation:, contact:) }
  let(:relation) { Project.all }
  let(:contact) do
    FactoryBot.build(:contact,
                     desired_works__c:     desired_works,
                     experienced_works__c: experienced_works).decorate
  end
  let(:all_works) { Contact::DesiredWork.pluck(:value) + Contact::ExperiencedWork.pluck(:value) }
  let(:desired_works) { [Contact::DesiredWork.first.value] }
  let(:experienced_works) { [Contact::ExperiencedWork.last.value] }
  let(:dissociated_works) { all_works - desired_works - experienced_works }
  let(:dissociated_work) { dissociated_works.shuffle.take(1) }

  named_let!(:project_unmatched_all) do
    FactoryBot.create(:project, experiencecatergory__c: dissociated_work)
  end
  named_let!(:project_matched_all) do
    FactoryBot.create(:project, experiencecatergory__c: experienced_works + desired_works + dissociated_work)
  end
  named_let!(:project_matched_all__desired_works) do
    FactoryBot.create(:project, experiencecatergory__c: desired_works)
  end
  named_let!(:project_matched_all__experienced_works) do
    FactoryBot.create(:project, experiencecatergory__c: experienced_works)
  end

  describe '#selected_projects_with_all' do
    subject { ActiveType.cast(model.selected_projects_with_all, Project) }

    it do
      is_expected.to not_include(project_unmatched_all)
        .and include(project_matched_all)
        .and include(project_matched_all__desired_works)
        .and include(project_matched_all__experienced_works)
    end
  end
end
