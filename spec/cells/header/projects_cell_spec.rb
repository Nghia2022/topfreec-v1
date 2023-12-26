# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Header::ProjectsCell, type: :cell do
  controller ApplicationController

  subject(:described_cell) { cell(described_class) }

  describe 'cell rendering' do
    describe 'rendering #show' do
      subject(:perform) { described_cell.call(:show) }

      it do
        is_expected.to have_content('案件を見つける')
      end

      # TODO: #3440 FeatureSwitchの分岐を削除
      describe ':new_project_category_meta of Feature Switch' do
        context 'with true' do
          before do
            FeatureSwitch.enable :new_project_category_meta
          end

          it do
            is_expected.to have_link('IT PM/PMO', href: slug_projects_path('it-project-management'))
              .and have_link('PM/PMO', href: slug_projects_path('project-management'))
              .and have_link('BPR/RPA/BPO', href: slug_projects_path('business-improvement'))
              .and have_link('システム設計/開発/導入', href: slug_projects_path('system-design-system'))
              .and have_link('SAP', href: slug_projects_path('sap'))
          end
        end

        context 'with false' do
          it do
            is_expected.to have_link('IT PM/PMO', href: projects_path(categories: ['ITプロジェクト管理']))
              .and have_link('PM/PMO', href: projects_path(categories: ['プロジェクト管理']))
              .and have_link('BPR/RPA/BPO', href: projects_path(categories: ['業務改善(BPR/RPA/BPO)']))
          end
        end
      end
    end
  end
end
