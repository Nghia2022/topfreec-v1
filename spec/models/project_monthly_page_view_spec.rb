# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectMonthlyPageView, type: :model do
  let!(:project_a) do
    FactoryBot.create(:project,
                      :with_impressions,
                      impression_count:    3,
                      impression_datetime: 1.month.ago.beginning_of_month)
  end
  let!(:project_b) do
    FactoryBot.create(:project,
                      :with_impressions,
                      impression_count:    1,
                      impression_datetime: 1.month.ago.end_of_month)
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
                      impression_datetime: 2.months.ago)
  end

  describe '.refresh' do
    subject { described_class.refresh(concurrently: false) }

    it do
      expect do
        subject
      end.to change { described_class.count }.from(0).to(2)
    end

    it do
      subject
      expect(described_class.all).to contain_exactly(project_a.project_monthly_page_view, project_b.project_monthly_page_view)
    end

    it 'all projects should be aggregate' do
      subject
      expect(project_a.project_monthly_page_view).to have_attributes(pv: 3)
      expect(project_b.project_monthly_page_view).to have_attributes(pv: 1)
      expect(project_c.project_monthly_page_view).to be_nil
      expect(project_d.project_monthly_page_view).to be_nil
    end
  end
end

# == Schema Information
#
# Table name: project_monthly_page_views
#
#  pv         :bigint
#  project_id :integer          primary key
#
# Indexes
#
#  index_project_monthly_page_views_on_project_id  (project_id) UNIQUE
#  index_project_monthly_page_views_on_pv          (pv)
#
