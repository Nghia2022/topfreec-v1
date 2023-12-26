# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ProjectCell, type: :cell do
  controller ApplicationController
  let(:options) { {} }
  let(:model) { FactoryBot.build_stubbed(:project, attributes).decorate }
  let(:described_cell) { cell(described_class, model, options) }
  let(:attributes) { {} }
  context 'cell rendering' do
    describe 'rendering #card' do
      subject { described_cell.call(:card) }

      let(:attributes) { { web_reward_min__c: 120, web_reward_max__c: 200 } }

      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      before do
        allow(described_cell).to receive(:current_user).and_return(fc_user)
        allow(described_cell).to receive(:fc_user_signed_in?).and_return(true)
      end

      it do
        is_expected.to [
          have_selector(:testid, 'project/card'),
          have_content(model.project_name),
          have_link(href: project_path(id: model)),
          have_content('120-200万円 / 月'),
          have_content(model.work_options),
          have_content(model.description),
          have_no_link('会員登録フォームに進む'),
          have_no_link('サービス内容を確認')
        ].inject(:and)
      end
    end

    describe 'rendering #detail' do
      subject { described_cell.call(:detail) }
      let(:model) { FactoryBot.build_stubbed(:project, attributes).decorate }
      let(:attributes) { { web_publishdatetime__c: Time.current } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      before do
        allow(described_cell).to receive(:current_user).and_return(fc_user)
        allow(described_cell).to receive(:fc_user_signed_in?).and_return(true)
      end

      it do
        is_expected.to have_selector(:testid, 'project/detail')
          .and have_content(model.project_name)
          .and have_content(model.project_id)
          .and have_content(model.description)
          .and have_no_link('会員登録フォームに進む')
          .and have_no_link('サービス内容を確認')
          .and have_no_link('ログインして確認')
      end

      context 'work_section' do
        context 'is present' do
          let(:attributes) { { web_worksection__c: '営業部門の新設チーム' } }

          it 'draw work_section' do
            is_expected.to have_content '配属部署名（予定）'
          end
        end

        context 'is not present' do
          let(:attributes) { { web_worksection__c: '' } }

          it 'do not draw work_section' do
            is_expected.not_to have_content '配属部署名（予定）'
          end
        end
      end

      context 'work_environment' do
        context 'is present' do
          let(:attributes) { { web_workenvironment__c: '当事務所は少数精鋭制です。' } }

          it 'draw work_section' do
            is_expected.to have_content '配属部署の体制/特徴'
          end
        end

        context 'is not present' do
          let(:attributes) { { web_worksection__c: '' } }

          it 'do not draw work_section' do
            is_expected.not_to have_content '配属部署の体制/特徴'
          end
        end
      end

      context 'experience categories' do
        let(:attributes) { { experiencecatergory__c: %w[PM/PMO DX推進 営業] } }
        it 'draw experience categories' do
          is_expected.to have_content 'PM/PMO, DX推進, 営業'
        end
      end

      context 'human resources column' do
        let(:attributes) { { web_human_resource_sub__c: human_resources_sub } }
        context 'if human_resources_sub is present' do
          let(:human_resources_sub) { 'HUMAN_RESOURCES_SUB' }
          it 'draw label and human_resources_sub' do
            is_expected.to have_content('HUMAN_RESOURCES_SUB')
              .and have_content('必須')
              .and have_content('尚可')
          end
        end

        context 'if human_resources_sub is not present' do
          let(:human_resources_sub) { '' }
          it 'do not draw label' do
            is_expected.not_to have_content('必須')
            is_expected.not_to have_content('尚可')
          end
        end
      end

      context 'compensations' do
        let(:attributes) { { web_reward_min__c: 100, web_reward_max__c: 150, web_reward_note__c: '※上記をベースに応相談' } }

        it do
          is_expected.to have_content('100-150')
            .and have_content('100〜150万円')
            .and have_content('※上記をベースに応相談')
        end
      end

      context 'operating_rates' do
        let(:attributes) { { web_kado_min__c: '50', web_kado_max__c: '80', web_kado_note__c: '※稼働率は応相談です。' } }
        it do
          is_expected.to have_content('50％ 〜 80％')
            .and have_content('※稼働率は応相談です。')
        end
      end

      context 'work_location' do
        let(:attributes) do
          {
            work_prefectures__c: %w[北海道 青森県],
            work_options__c:     %w[完全出社 一部リモート],
            web_place_note__c:   '※該施設は関西にありますが'
          }
        end

        it do
          is_expected.to have_content('北海道, 青森県')
            .and have_content('完全出社, 一部リモート')
            .and have_content('※該施設は関西にありますが')
        end
      end

      context 'participation_period' do
        let(:attributes) { { web_period__c: '3ヶ月〜' } }

        it { is_expected.to have_content('3ヶ月〜') }
      end

      context 'dispatch_contract' do
        context 'when true' do
          before do
            allow(described_cell).to receive(:dispatch_contract?).and_return(true)
          end

          it do
            is_expected.to have_content('※派遣契約の案件にご参画いただくためには、株式会社みらいワークス')
          end
        end

        context 'when false' do
          it do
            is_expected.to have_no_content('※派遣契約の案件にご参画いただくためには、株式会社みらいワークス')
          end
        end
      end

      context 'when fc_user not signed in' do
        before do
          allow(described_cell).to receive(:current_user).and_return(nil)
          allow(described_cell).to receive(:fc_user_signed_in?).and_return(false)
        end

        it do
          is_expected.to have_selector(:testid, 'project/detail')
            .and have_content(model.project_name)
            .and have_content(model.project_id)
            .and have_content(model.description)
            .and have_link('会員登録フォームに進む', href: new_fc_user_registration_path)
            .and have_link('サービス内容を確認', href: service_page_path)
            .and have_link('ログインして確認', href: new_fc_user_session_path)
        end
      end
    end
  end

  describe 'rendering #entry_button' do
    subject { described_cell.call(:entry_button) }

    before do
      allow(described_cell).to receive(:current_user).and_return(fc_user)
    end

    context 'when user is fc company' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :fc_company) }

      it do
        is_expected.to have_no_link('この案件に応募する')
          .and have_button('受付終了', disabled: true)
      end
    end

    context 'when entry not exists and not signed in' do
      let(:options) { { entry_exists: false } }
      let(:fc_user) { nil }

      before do
        allow(described_cell).to receive(:fc_user_signed_in?).and_return(false)
      end

      it do
        is_expected.to have_link('この案件に応募する', href: new_fc_user_session_path)
            .and have_no_button('この案件に応募する')
      end
    end

    context 'when entry not exists and signed in' do
      let(:options) { { entry_exists: false } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      before do
        allow(described_cell).to receive(:fc_user_signed_in?).and_return(true)
      end

      it do
        is_expected.to have_selector("button[data-href='#{new_project_entry_path(model)}']", text: 'この案件に応募する')
            .and have_no_button('受付終了', disabled: true)
            .and have_no_link('この案件に応募する')
      end
    end

    context 'when entry exists' do
      let(:options) { { entry_exists: true } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it do
        is_expected.to have_no_link('応募済み')
          .and have_button('応募済み', disabled: true)
      end
    end

    context 'when entry stopped' do
      let(:options) { { entry_stopped: true } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it do
        is_expected.to have_no_link('受付終了')
            .and have_button('受付終了', disabled: true)
      end
    end

    context 'when entry exists and entry stopped' do
      let(:options) { { entry_exists: true, entry_stopped: true } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it do
        is_expected.to have_no_link('受付終了')
          .and have_button('受付終了', disabled: true)
      end
    end

    context 'when entry exists and entry closed' do
      let(:options) { { entry_exists: true } }
      let(:attributes) { { isclosedwebreception__c: true } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it do
        is_expected.to have_no_link('応募済み')
          .and have_button('応募済み', disabled: true)
      end
    end
  end

  describe 'rendering #entry_button_for_index' do
    subject { described_cell.call(:entry_button_for_index) }

    before do
      allow(described_cell).to receive(:current_user).and_return(fc_user)
    end

    context 'when user is fc company' do
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user, :fc_company) }

      it do
        is_expected.to have_no_link('今すぐ応募する')
            .and have_button('受付終了', disabled: true)
      end
    end

    context 'when entry not exists and not signed in' do
      let(:options) { { entry_exists: false } }
      let(:fc_user) { nil }

      before do
        allow(described_cell).to receive(:fc_user_signed_in?).and_return(false)
      end

      it do
        is_expected.to have_link('今すぐ応募する', href: new_fc_user_session_path)
            .and have_no_button('今すぐ応募する')
      end
    end

    context 'when entry not exists and signed in' do
      let(:options) { { entry_exists: false } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      before do
        allow(described_cell).to receive(:fc_user_signed_in?).and_return(true)
      end

      it do
        is_expected.to have_selector("button[data-href='#{new_project_entry_path(model)}']", class: 'jsModalOpen', text: '今すぐ応募する')
            .and have_no_button('受付終了', disabled: true)
            .and have_no_link('今すぐ応募する')
      end
    end

    context 'when entry exists' do
      let(:options) { { entry_exists: true } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it do
        is_expected.to have_no_link('応募済み')
          .and have_button('応募済み', disabled: true)
      end
    end

    context 'when entry stopped' do
      let(:options) { { entry_stopped: true } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it do
        is_expected.to have_no_link('受付終了')
          .and have_button('受付終了', disabled: true)
      end
    end

    context 'when entry exists and entry stopped' do
      let(:options) { { entry_exists: true, entry_stopped: true } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it do
        is_expected.to have_no_link('受付終了')
          .and have_button('受付終了', disabled: true)
      end
    end

    context 'when entry exists and entry closed' do
      let(:options) { { entry_exists: true } }
      let(:attributes) { { isclosedwebreception__c: true } }
      let(:fc_user) { FactoryBot.build_stubbed(:fc_user) }

      it do
        is_expected.to have_no_link('応募済み')
          .and have_button('応募済み', disabled: true)
      end
    end
  end
  describe 'cell methods' do
    describe '#human_resources' do
      let(:model) { FactoryBot.build(:project, web_human_resource_main__c: "<p>ほげ\nふが</p>").decorate }

      it do
        expect(described_cell.human_resources).to eq '&lt;p&gt;ほげ<br>ふが&lt;/p&gt;'
      end
    end

    describe '#human_resources_sub' do
      let(:model) { FactoryBot.build(:project, web_human_resource_sub__c: "<p>ほげ\nふが</p>").decorate }

      it do
        expect(described_cell.human_resources_sub).to eq '&lt;p&gt;ほげ<br>ふが&lt;/p&gt;'
      end
    end

    describe '#client_category_name' do
      let(:model) { FactoryBot.build(:project, web_clientname__c: client_name).decorate }

      subject { described_cell.client_category_name }

      context 'web_clientname__c is not blanked' do
        let(:client_name) { '株式会社テスト' }

        it 'should be return myself' do
          is_expected.to eq '株式会社テスト'
        end
      end

      context 'web_clientname__c is blanked' do
        let(:client_name) { '' }

        it 'should be return 非公開' do
          is_expected.to eq '非公開'
        end
      end
    end

    describe '#experience_categories_text' do
      let(:model) { FactoryBot.build(:project, :with_category, main_category: %w[PM/PMO DX推進 営業]).decorate }

      it { expect(described_cell.experience_categories_text).to eq 'PM/PMO, DX推進, 営業' }
    end

    describe '#operating_rates' do
      using RSpec::Parameterized::TableSyntax

      # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      where(:operating_rate_min, :operating_rate_max, :result) do
        '50' | '80' | '50％ 〜 80％'
        '50' | nil  | '50％'
        ''   | '80' | '80％'
        nil  | nil  | ''
        '50' | '50' | '50％'
      end
      # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

      with_them do
        let(:model) { FactoryBot.build(:project, web_kado_min__c: operating_rate_min, web_kado_max__c: operating_rate_max).decorate }

        it { expect(described_cell.operating_rates).to eq result }
      end
    end

    describe '#operator_image' do
      subject { described_cell.operator_image }

      let(:model) { FactoryBot.build(:project, web_owner_pictureflag__c: flag, web_picture__c:).decorate }
      let(:web_picture__c) { 'https://example.com/image.png' }
      let(:default_url) { 'https://res.cloudinary.com/miraiworksdev/image/upload/t_user_profile/v1/projects/operators/default.png' }

      context 'if web_owner_pictureflag__c is true' do
        let(:flag) { true }

        context 'when picture is valid URL' do
          it { is_expected.to eq 'https://example.com/image.png' }
        end

        context 'when picture is invalid URL' do
          let(:web_picture__c) { 'invalid' }

          it { is_expected.to eq default_url }
        end
      end

      context 'when web_picture__c is cloudinary' do
        let(:web_picture__c) { 'https://res.cloudinary.com/miraiworksdev/image/upload/v1587105942/sample.jpg' }
        let(:flag) { true }

        it do
          is_expected.to eq 'https://res.cloudinary.com/miraiworksdev/image/upload/t_user_profile/v1587105942/sample.jpg'
        end
      end

      context 'if web_owner_pictureflag__c is false' do
        let(:flag) { false }

        it do
          is_expected.to eq default_url
        end
      end
    end

    describe '#operator_name' do
      let(:model) { FactoryBot.build(:project, owner__user_name__c: '山田太郎').decorate }

      subject { described_cell.operator_name }

      it { is_expected.to eq '山田太郎' }
    end

    context 'participation_period' do
      let(:past) { 1.month.before(now).to_date }
      let(:past_same_month) { 1.day.before(now).to_date }
      let(:now) { '2022-01-15'.to_date }
      let(:future) { 1.month.after(now).to_date }

      let(:future_text) { I18n.ln(future, format: :without_date) }
      let(:past_same_month_text) { I18n.ln(past_same_month, format: :without_date) }

      around do |ex|
        travel_to(now) { ex.run }
      end

      describe 'participation_period?' do
        using RSpec::Parameterized::TableSyntax

        # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
        where(:from, :to, :closed, :visible) do
          future | future | false | true
          future | future | true  | false
          future | past   | false | false
        end
        # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

        with_them do
          let(:future) { 1.day.after.to_date }
          let(:attributes) { { web_period_from__c: from, web_period_to__c: to, isclosedwebreception__c: closed } }

          it { expect(described_cell.participation_period?).to eq(visible) }
        end
      end

      describe 'participation_period_date' do
        using RSpec::Parameterized::TableSyntax

        # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
        where(:from, :to, :date) do
          future          | future | "#{future_text} 〜 #{future_text}"
          future          | nil    | "#{future_text} 〜 個別調整"
          nil             | future | "ご提案時調整 〜 #{future_text}"
          past            | nil    | 'ご提案時調整'
          past_same_month | nil    | "#{past_same_month_text} 〜"
          nil             | nil    | nil
        end
        # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

        with_them do
          let(:attributes) { { web_period_from__c: from, web_period_to__c: to } }

          it { expect(described_cell.participation_period_date).to eq(date) }
        end
      end

      describe 'participation_period_duration' do
        using RSpec::Parameterized::TableSyntax

        # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
        where(:from, :to, :period, :duration) do
          future | future | '1ヶ月' | '1ヶ月'
          past   | nil    | '1ヶ月' | nil
        end
        # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands

        with_them do
          let(:attributes) { { web_period_from__c: from, web_period_to__c: to, web_period__c: period } }

          it { expect(described_cell.participation_period_duration).to eq(duration) }
        end
      end
    end
  end
end
