# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::SettingCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact, attributes)) }
  let(:fc_user) { FcUserDecorator.decorate(FactoryBot.build_stubbed(:fc_user, fc_user_trait)) }
  let(:attributes) { {} }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      before do
        allow(described_cell).to receive(:current_fc_user).and_return(fc_user)
        allow(described_cell).to receive(:current_user).and_return(fc_user)
        allow_any_instance_of(Mypage::Fc::Profiles::GeneralCell).to receive(:show).and_return('基本情報')
      end

      context 'when user is fc' do
        let(:fc_user_trait) { :activated }

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/setting/show')
              .and have_content('ログイン設定')
              .and have_content('基本情報')
        end
      end

      context 'when user is fc company' do
        let(:fc_user_trait) { :fc_company }

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/setting/show')
              .and have_content('ログイン設定')
              .and have_no_content('基本情報')
        end
      end
    end

    describe 'rendering #detail' do
      let(:sf_content_document) { FactoryBot.build(:sf_content_document) }

      subject { described_cell.call(:detail) }

      before do
        allow(described_cell).to receive(:current_user).and_return(fc_user)
        allow(described_cell).to receive(:person).and_return(fc_user.contact)
        allow(Salesforce::ContentDocument).to receive(:find_by).and_return(sf_content_document)
        allow_any_instance_of(Mypage::Fc::Settings::ResumeCell).to receive(:current_user).and_return(fc_user)
      end

      # TODO: #3353 contextブロックの削除
      context 'when :new_work_category of Feature Switch is false' do
        context 'when user is fc' do
          let(:fc_user_trait) { :activated }

          it do
            is_expected.to have_content('希望条件')
              .and have_content('案件紹介リクエスト')
              .and have_content('資格・レジュメ')
          end
        end

        context 'when user is fc company' do
          let(:fc_user_trait) { :fc_company }

          it do
            is_expected.to have_no_content('希望条件')
              .and have_no_content('案件紹介リクエスト')
              .and have_no_content('資格・レジュメ')
              .and have_no_selector(:testid, 'mypage/fc/settings/desired_condition/new_show')
          end
        end
      end

      # TODO: #3353 丸ごと削除
      context 'when :new_work_category of Feature Switch is true' do
        let(:fc_user_trait) { :activated }

        before do
          Flipper.enable :new_work_category
        end

        it do
          is_expected.to have_selector(:testid, 'mypage/fc/settings/desired_condition/new_show')
        end
      end
    end
  end
end
