# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Corp::Pages', type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /corp' do
    it do
      is_expected.to redirect_to(corp_root_path)
    end
  end

  describe 'GET /corp/' do
    it do
      is_expected.to have_http_status(:ok)
    end

    describe 'content' do
      subject do
        send_request
        response.body
      end

      it do
        is_expected.to have_content '最適なプロの即戦力を'
      end
    end
  end

  describe 'GET /corp/performance/' do
    it do
      is_expected.to have_http_status(:ok)
    end

    context 'content' do
      subject do
        send_request
        response.body
      end

      it do
        is_expected.to have_content 'Performance'
      end
    end
  end

  describe 'GET /corp/terms' do
    it do
      is_expected.to have_http_status(:ok)
    end

    describe 'content' do
      subject do
        send_request
        response.body
      end

      it do
        is_expected.to have_content 'プロフェッショナル人材サービス 利用規約'
      end
    end
  end

  describe 'GET /corp/statistics' do
    it do
      is_expected.to redirect_to(corp_statistics_page_path)
    end
  end

  describe 'GET /corp/statistics/' do
    it do
      is_expected.to have_http_status(:ok)
    end

    describe 'content' do
      subject do
        send_request
        response.body
      end

      it do
        is_expected.to have_content '登録コンサルタントの約40%が'
      end

      it do
        is_expected.to have_link('お問い合わせはこちら', href: contact_url)
      end
    end
  end
end
