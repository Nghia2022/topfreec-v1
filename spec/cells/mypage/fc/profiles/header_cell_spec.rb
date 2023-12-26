# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Profiles::HeaderCell, type: :cell do
  context 'cell rendering' do
    controller ApplicationController

    let(:options) { {} }
    let(:model) { FactoryBot.build_stubbed(:fc_user, :activated) }
    let(:described_cell) { cell(described_class, model, options) }

    context 'rendering #show' do
      subject { described_cell.call(:show) }

      context 'when user is fc' do
        let(:model) { FactoryBot.build_stubbed(:fc_user, :activated) }
        let(:decorated_model) { model.decorate }
        let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, :fc)) }

        before do
          allow(controller).to receive(:current_user).and_return(model)
          allow_any_instance_of(Devise::Controllers::Helpers).to receive(:current_fc_user).and_return(model)
          allow_any_instance_of(ApplicationController).to receive(:decorated_fc_user).and_return(decorated_model)
          allow_any_instance_of(ApplicationController).to receive(:current_fc_profile).and_return(profile)
        end

        it do
          is_expected.to have_link(text: '設定情報', href: mypage_fc_settings_path)
            .and have_link(href: mypage_fc_directions_path)
            .and have_link(text: 'マイページ', href: mypage_root_path)
        end
      end

      context 'when user is fc_company' do
        let(:model) { FactoryBot.build_stubbed(:fc_user, :fc_company) }
        let(:decorated_model) { model.decorate }
        let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, :fc)) }

        before do
          allow_any_instance_of(Devise::Controllers::Helpers).to receive(:current_fc_user).and_return(model)
          allow_any_instance_of(ApplicationController).to receive(:current_fc_profile).and_return(profile)
        end

        it do
          is_expected.to have_link(text: '設定情報', href: mypage_fc_settings_path)
          .and have_link(text: 'マイページ', href: mypage_root_path)
        end
      end
    end

    describe '#show_sp' do
      subject { described_cell.call(:show_sp) }

      context 'when user is fc' do
        let(:model) { FactoryBot.build_stubbed(:fc_user, :activated) }
        let(:decorated_model) { model.decorate }
        let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, :fc)) }

        before do
          allow(controller).to receive(:current_user).and_return(model)
          allow_any_instance_of(Devise::Controllers::Helpers).to receive(:current_fc_user).and_return(model)
          allow_any_instance_of(ApplicationController).to receive(:decorated_fc_user).and_return(decorated_model)
          allow_any_instance_of(ApplicationController).to receive(:current_fc_profile).and_return(profile)
        end

        it do
          is_expected.to have_link(text: 'マイページ', href: mypage_root_path)
            .and have_link(text: '案件を見つける')
            .and have_link(text: '業務指示確認')
            .and have_link(text: 'お役立ち情報')
            .and have_link(text: 'よくある質問')
            .and have_link(text: '設定情報', href: mypage_fc_settings_path)
        end
      end

      context 'when user is fc_company' do
        let(:model) { FactoryBot.build_stubbed(:fc_user, :fc_company) }
        let(:decorated_model) { model.decorate }
        let(:profile) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, :fc)) }

        before do
          allow_any_instance_of(Devise::Controllers::Helpers).to receive(:current_fc_user).and_return(model)
          allow_any_instance_of(ApplicationController).to receive(:current_fc_profile).and_return(profile)
        end

        it do
          is_expected.to have_link(text: 'マイページ', href: mypage_root_path)
            .and have_no_link(text: '案件を見つける')
            .and have_no_link(text: '業務指示確認')
            .and have_no_link(text: 'お役立ち情報')
            .and have_no_link(text: 'よくある質問')
            .and have_link(text: '設定情報', href: mypage_fc_settings_path)
        end
      end
    end
  end
end
