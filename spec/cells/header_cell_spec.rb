# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HeaderCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:model) { nil }
  let(:described_cell) { cell(described_class, model, options) }

  describe 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      before do
        allow(controller).to receive(:current_user).and_return(model)
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

      shared_examples '「miraiworks」ロゴの検証' do
        it do
          is_expected.to have_link(nil, href: mirai_works_url, target: '_blank')
        end
      end

      context 'when user is signed in as fc' do
        let(:model) { FactoryBot.build_stubbed(:fc_user, :activated) }
        let(:decorated_model) { model.decorate }
        let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, :fc)) }

        before do
          allow_any_instance_of(Devise::Controllers::Helpers).to receive(:current_fc_user).and_return(model)
          allow_any_instance_of(ApplicationController).to receive(:decorated_fc_user).and_return(decorated_model)
          allow_any_instance_of(ApplicationController).to receive(:current_fc_profile).and_return(profile)
        end

        it do
          is_expected.to have_no_link('ログイン')
            .and have_no_link('会員登録')
            .and have_link('マイページ', href: mypage_root_path)
            .and have_link('設定情報', href: mypage_fc_settings_path)
        end

        it_behaves_like '「miraiworks」ロゴの検証'

        context 'and passed action = :show' do
          let(:options) { { action: :show } }

          it do
            is_expected.to have_link('ログイン', href: new_fc_user_session_path)
              .and have_link('会員登録', href: new_fc_user_registration_path)
              .and have_no_link('マイページ')
              .and have_no_link('設定情報')
          end

          it_behaves_like '「miraiworks」ロゴの検証'
        end

        context 'but registration not completed yet' do
          before do
            model.registration_completed_at = nil
          end

          it do
            is_expected.to have_link('ログイン', href: new_fc_user_session_path)
              .and have_link('会員登録', href: new_fc_user_registration_path)
              .and have_no_link('マイページ')
              .and have_no_link('設定情報')
          end
        end
      end

      context 'when user is signed in as fc_company' do
        let(:model) { FactoryBot.build_stubbed(:fc_user, :fc_company) }
        let(:decorated_model) { model.decorate }
        let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact)) }

        before do
          allow_any_instance_of(Devise::Controllers::Helpers).to receive(:current_fc_user).and_return(model)
          allow_any_instance_of(ApplicationController).to receive(:decorated_fc_user).and_return(decorated_model)
          allow_any_instance_of(ApplicationController).to receive(:current_fc_profile).and_return(profile)
        end

        it do
          is_expected.to have_no_link('ログイン')
            .and have_no_link('会員登録')
            .and have_link('マイページ', href: mypage_root_path)
            .and have_link('設定情報', href: mypage_fc_settings_path)
        end

        it_behaves_like '「miraiworks」ロゴの検証'
      end

      context 'when user is signed in as client' do
        let(:model) { FactoryBot.build_stubbed(:client_user, :with_contact) }

        it do
          is_expected.to have_no_link('ログイン')
            .and have_no_link('会員登録')
            .and have_link('設定情報', href: mypage_client_settings_path)
        end

        it_behaves_like '「miraiworks」ロゴの検証'
      end

      context 'when user is not signed in' do
        let(:model) { nil }

        before do
          allow_any_instance_of(Devise::Controllers::Helpers).to receive(:fc_user_signed_in?).and_return(false)
        end

        it do
          is_expected.to have_link('ログイン', href: new_fc_user_session_path)
            .and have_link('会員登録', href: new_fc_user_registration_path)
            .and have_no_link('マイページ')
            .and have_no_link('設定情報')
        end

        it_behaves_like '「miraiworks」ロゴの検証'
      end

      describe 'when visit corp top page' do
        let(:options) { { action: :corp_top } }

        it do
          is_expected.to have_link('活用事例', href: client_case_url, count: 2)
            .and have_link('ビジネスコラム', href: client_business_column_url, count: 2)
            .and have_link('登録者内訳', href: client_statistics_url, count: 2)
            .and have_link('取引実績', href: client_case_url, count: 2)
            .and have_link('お問い合わせ', href: contact_business_pro_url)
            .and have_link('企業ログイン', href: new_client_user_session_path)
            .and have_no_link('会員登録')
        end
      end
    end
  end
end
