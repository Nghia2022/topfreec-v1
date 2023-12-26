# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::BusinessColumns', :erb, type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /corp/business-column' do
    it { is_expected.to have_http_status(:ok) }

    context 'with tag' do
      let(:params) do
        {
          tag: 'independent-entrepreneurial'
        }
      end

      it do
        is_expected.to have_http_status(:ok)
      end
    end
  end

  describe 'GET /corp/business-column?bccat=:tag' do
    let(:tag) { 'independent-entrepreneurial' }

    it { is_expected.to have_http_status(:ok) }
  end

  describe 'GET /corp/business-column/:id' do
    let(:model) { FactoryBot.build_stubbed(:business_column) }
    let(:id) { model.to_param }

    before do
      allow(Wordpress::BusinessColumn).to receive(:find_by!).and_return(model)
    end

    it { is_expected.to have_http_status(:ok) }

    describe 'share url' do
      subject do
        send_request
        response.body
      end

      it do
        is_expected.to have_link(href: "http://www.facebook.com/share.php?u=#{CGI.escape(request.original_url)}")
          .and have_link(href: "https://twitter.com/share?url=#{CGI.escape(request.original_url)}")
          .and have_link(href: "http://b.hatena.ne.jp/add?mode=confirm&url=#{CGI.escape(request.original_url)}")
      end
    end

    describe 'metatags with postmeta' do
      subject do
        send_request
        Capybara.string(response.body)
      end

      before do
        allow_any_instance_of(Wordpress::BusinessColumn).to receive(:post_title).and_return('タイトル')
        allow_any_instance_of(Wordpress::BusinessColumn).to receive(:post_content).and_return('本文')
        allow_any_instance_of(Wordpress::BusinessColumn).to receive(:wp_postmeta).and_return(
          [
            { meta_key: '_aioseop_keywords', meta_value: 'キーワード' },
            { meta_key: '_aioseop_description', meta_value: '概要' },
            { meta_key: 'thunbnail', meta_value: 'id' }

          ].map { |attrs| Wordpress::WpPostmetum.new(attrs) }
        )
        allow_any_instance_of(Wordpress::BusinessColumnDecorator).to receive(:thumbnail).and_return('http://example.com/')
      end

      it do
        is_expected.to have_title('(test) タイトル')
          .and(satisfy { |doc| doc.find('meta[name=description]', visible: false)[:content] == '概要' })
          .and(satisfy { |doc| doc.find('meta[name=keywords]', visible: false)[:content] == 'キーワード' })
          .and(satisfy { |doc| doc.find('meta[property="og:type"]', visible: false)[:content] == 'article' })
          .and(satisfy { |doc| doc.find('meta[property="og:title"]', visible: false)[:content] == 'タイトル' })
          .and(satisfy { |doc| doc.find('meta[property="og:site_name"]', visible: false)[:content] == 'フリーコンサルタント.jp' })
          .and(satisfy { |doc| doc.find('meta[property="og:url"]', visible: false)[:content] == url_for(model) })
          .and(satisfy { |doc| doc.find('meta[property="og:image"]', visible: false)[:content] == 'http://example.com/' })
          .and(satisfy { |doc| doc.find('meta[property="og:description"]', visible: false)[:content] == '本文' })
      end
    end
  end
end
