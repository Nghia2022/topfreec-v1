# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Profiles::GeneralCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { ProfileDecorator.decorate(FactoryBot.build_stubbed(:sf_contact)) }
  let(:fc_user) { FcUserDecorator.decorate(FactoryBot.build_stubbed(:fc_user)) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_fc_user).and_return(fc_user)
  end

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_selector(:testid, 'mypage/fc/profiles/general/show')
          .and have_content('基本情報')
          .and have_content(model.first_name)
          .and have_content(model.first_name_kana)
          .and have_content(model.last_name)
          .and have_content(model.last_name_kana)
          .and have_content(model.phone)
          .and have_content(model.phone2)
      end
    end
  end

  context 'cell method' do
    describe '#address' do
      it do
        expect(described_cell.address).to eq('東京都渋谷区広尾１丁目１−３９')
      end
    end

    describe '#zipcode' do
      it do
        expect(described_cell.zipcode).to eq('150-0012')
      end
    end

    describe '#profile_image_tag' do
      subject { Capybara.string(described_cell.send(:profile_image_tag)) }

      context 'when upload: false' do
        let(:options) { { upload_profile_image: false } }

        it do
          is_expected.to have_selector('img', class: 'profile-pic')
            .and have_no_selector('img', class: 'profile-pic upload-trigger')
        end
      end

      context 'when upload: true' do
        let(:options) { { upload_profile_image: true } }

        it do
          is_expected.to have_selector('img', class: 'profile-pic upload-trigger')
        end
      end
    end
  end
end
