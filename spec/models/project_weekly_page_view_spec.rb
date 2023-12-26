# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectWeeklyPageView, type: :model do
  let!(:project_a) do
    FactoryBot.create(:project,
                      :with_impressions,
                      impression_count:    2,
                      impression_datetime: 1.week.ago.beginning_of_week)
  end
  let!(:project_b) do
    FactoryBot.create(:project,
                      :with_impressions,
                      impression_count:    1,
                      impression_datetime: 1.week.ago.end_of_week)
  end
  let!(:project_c) do
    FactoryBot.create(:project,
                      :with_impressions,
                      impression_count:    1,
                      impression_datetime: Time.current)
  end
  let!(:project_d) do
    FactoryBot.create(:project,
                      :with_impressions,
                      impression_count:    1,
                      impression_datetime: 1.month.ago)
  end

  describe '.refresh' do
    subject { described_class.refresh(concurrently: false) }

    xit do
      expect do
        subject
      end.to change { described_class.count }.from(0).to(2)
    end

    xit do
      subject
      expect(described_class.all).to contain_exactly(project_a.project_weekly_page_view, project_b.project_weekly_page_view)
    end

    xit 'all projects should be aggregate' do
      subject
      expect(project_a.project_weekly_page_view).to have_attributes(pv: 2)
      expect(project_b.project_weekly_page_view).to have_attributes(pv: 1)
      expect(project_c.project_monthly_page_view).to be_nil
      expect(project_d.project_monthly_page_view).to be_nil
    end
  end
end

# == Schema Information
#
# Table name: project_weekly_page_views
#
#  pv         :bigint
#  project_id :integer          primary key
#
# Indexes
#
#  index_project_weekly_page_views_on_project_id  (project_id) UNIQUE
#  index_project_weekly_page_views_on_pv          (pv)
#
