# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LandingPages::RegistrationForm, type: :model do
  describe 'validations' do
    it do
      is_expected.to validate_presence_of(:last_name).with_message('お名前（姓）を入力してください')
    end

    it do
      is_expected.to validate_presence_of(:first_name).with_message('お名前（名）を入力してください')
    end

    it do
      is_expected.to validate_presence_of(:last_name_kana).with_message('お名前（姓カナ）を入力してください')
    end

    it do
      is_expected.to validate_presence_of(:first_name_kana).with_message('お名前（名カナ）を入力してください')
    end

    describe '#email' do
      it do
        is_expected.to validate_presence_of(:email).with_message('メールアドレスを入力してください')
      end

      describe 'uniquness in fc_user' do
        let(:fc_user) { FactoryBot.create(:fc_user) }

        context 'when email is uniq' do
          let(:landing_page) { LandingPages::RegistrationForm.new(email: 'test@sample.com') }

          it do
            landing_page.valid?
            expect(landing_page.errors[:email]).not_to include('メールアドレスが利用できません')
          end
        end

        context 'when email is not uniq' do
          let(:landing_page) { LandingPages::RegistrationForm.new(email: fc_user.email) }

          it do
            landing_page.valid?
            expect(landing_page.errors[:email]).to include('メールアドレスが利用できません')
          end
        end
      end
    end

    describe '#phone' do
      it do
        is_expected.to validate_presence_of(:phone).with_message('電話番号を入力してください')
      end

      describe 'format' do
        it do
          is_expected.to not_allow_values('a', '123').for(:phone).with_message('電話番号は不正な値です')
        end
      end
    end

    describe '#work_area1' do
      it do
        is_expected.to validate_presence_of(:work_area1).with_message('第一希望を選択してください')
      end
    end

    describe '#work_area2' do
      subject { LandingPages::RegistrationForm.new(work_area1: nil) }
      let(:work_area) { LandingPages::RegistrationForm.work_area1s.values.first }

      it do
        is_expected.to not_allow_value(work_area).for(:work_area2).with_message('第二希望を選択しないでださい')
      end
    end

    describe '#work_area3' do
      subject { LandingPages::RegistrationForm.new(work_area2: nil) }
      let(:work_area) { LandingPages::RegistrationForm.work_area1s.values.first }

      it do
        is_expected.to not_allow_value(work_area).for(:work_area3).with_message('第三希望を選択しないでださい')
      end
    end
  end
end
