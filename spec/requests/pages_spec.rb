# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:scope) { nil }
  let(:response_body) { subject.body }

  shared_examples 'content' do
    before do
      send_request
    end

    subject do
      Capybara.string(response.body).then do |doc|
        (scope.presence && doc.find(scope)) || doc
      end
    end
  end

  describe 'GET /terms' do
    it { is_expected.to have_http_status(:ok) }

    describe 'content' do
      include_examples 'content'

      it do
        is_expected.to have_title('サービス利用規約｜コンサル案件紹介の契約詳細')
      end
    end

    it do
      expect(response_body).to have_selector(:testid, 'pages/terms')
    end
  end

  describe 'GET /nda' do
    it { is_expected.to have_http_status(:ok) }

    describe 'content' do
      include_examples 'content'

      it do
        is_expected.to have_title('機密保持の誓約について')
      end
    end

    it do
      expect(response_body).to have_selector(:testid, 'pages/nda')
    end
  end

  describe 'GET /policy' do
    it { is_expected.to have_http_status(:redirect) }
  end

  describe 'GET /support' do
    it { is_expected.to have_http_status(:ok) }

    describe 'content' do
      include_examples 'content'

      it do
        is_expected.to have_title('登録コンサルのサポートメニュー')
      end
    end

    it do
      expect(response_body).to have_selector(:testid, 'pages/support')
    end

    describe 'FeatureSwitch :new_ideco' do
      context 'with true' do
        before do
          FeatureSwitch.enable :new_ideco
        end

        it do
          expect(response_body).to include 'https://401k.nomura.co.jp/api/capa0000?contractCd=9'
        end
      end

      context 'with false' do
        it do
          expect(response_body).to include 'https://401k.nomura.co.jp/dc/auth/main?_ControlID=WebReceptControl&amp;ContractCd=9'
        end
      end
    end
  end

  describe 'GET /service' do
    it { is_expected.to have_http_status(:ok) }

    describe 'content' do
      include_examples 'content'

      describe 'breadcrumbs' do
        it do
          is_expected.to have_link('TOP', href: root_path)
            .and have_link('サービス紹介', href: service_page_path)
        end
      end
    end

    it do
      expect(response_body).to have_selector(:testid, 'pages/service')
    end
  end

  describe 'GET /staff' do
    it { is_expected.to have_http_status(:ok) }

    describe 'content' do
      include_examples 'content'

      it do
        is_expected.to have_title('コンサルを支えるスタッフ紹介')
          .and have_text('スタッフ紹介')
      end
      describe 'breadcrumbs' do
        it do
          is_expected.to have_link('TOP', href: root_path)
            .and have_link('サービス紹介', href: service_page_path)
            .and have_link('スタッフ紹介', href: staff_page_path)
        end
      end
    end

    it do
      expect(response_body).to have_selector(:testid, 'pages/staff')
    end
  end

  describe 'GET /service/flow' do
    it { is_expected.to have_http_status(:ok) }

    describe 'content' do
      include_examples 'content'

      it do
        is_expected.to have_text('サービスの流れ')
          .and have_link('今すぐフリーコンサルタント.jpに会員登録する', href: new_fc_user_registration_path)
      end

      describe 'breadcrumbs' do
        it do
          is_expected.to have_link('TOP', href: root_path)
            .and have_link('サービス紹介', href: service_page_path)
            .and have_link('サービスの流れ', href: service_flow_page_path)
        end
      end
    end

    it do
      expect(response_body).to have_selector(:testid, 'pages/service_flow')
    end
  end

  describe 'GET /sitemap' do
    it { is_expected.to have_http_status(:ok) }

    describe 'content' do
      include_examples 'content'

      it do
        is_expected.to have_text('サイトマップ')
      end

      describe 'breadcrumbs' do
        it do
          is_expected.to have_link('TOP', href: root_path)
            .and have_link('サイトマップ', href: sitemap_page_path)
        end
      end
    end
  end
end
