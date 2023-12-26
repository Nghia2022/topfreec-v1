# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectDailyPageView, type: :model do
  let!(:project_a) do
    FactoryBot.create(:project,
                      :with_impressions,
                      impression_count:    1,
                      impression_datetime: 1.day.ago.beginning_of_day)
  end
  let!(:project_b) do
    FactoryBot.create(:project,
                      :with_impressions,
                      impression_count:    2,
                      impression_datetime: 1.day.ago.end_of_day)
  end

  describe '.popularity' do
    subject { described_class.popularity }

    before { described_class.refresh }

    it do
      is_expected.to eq [project_b.project_daily_page_view, project_a.project_daily_page_view]
    end

    it do
      is_expected.to match(
        [
          have_attributes(pv: 2),
          have_attributes(pv: 1)
        ]
      )
    end
  end

  describe '.refresh' do
    it do
      expect do
        described_class.refresh
      end.to change { described_class.popularity.size }.from(0).to(2)
    end
  end
end

# == Schema Information
#
# Table name: project_daily_page_views
#
#  pv         :bigint
#  project_id :integer          primary key
#
# Indexes
#
#  index_project_daily_page_views_on_project_id  (project_id) UNIQUE
#  index_project_daily_page_views_on_pv          (pv)
#
