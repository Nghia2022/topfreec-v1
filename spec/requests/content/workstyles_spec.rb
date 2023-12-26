# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::Workstyles', :erb, type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /workstyle' do
    it { is_expected.to have_http_status(:ok) }

    it do
      expect(subject.body).to have_selector(:testid, 'content/workstyles/index')
    end
  end

  describe 'GET /workstyle/:id' do
    let(:model) { FactoryBot.build_stubbed(:workstyle) }
    let(:id) { model.to_param }

    it_behaves_like 'redirect with status moved permanently'
  end

  describe 'GET /workstyle/:id/' do
    let(:model) { FactoryBot.build_stubbed(:workstyle) }
    let(:id) { model.to_param }

    before do
      allow_any_instance_of(Content::WorkstylesController).to receive(:workstyle).and_return(model.decorate)
    end

    it { is_expected.to have_http_status(:ok) }

    it do
      expect(subject.body).to have_selector(:testid, 'content/workstyles/show')
    end

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
        allow_any_instance_of(Wordpress::Workstyle).to receive(:post_title).and_return('タイトル')
        allow_any_instance_of(Wordpress::Workstyle).to receive(:wp_postmeta).and_return(
          [
            { meta_key: 'article-excerpt', meta_value: '概要' },
            { meta_key: '_aioseop_keywords', meta_value: 'キーワード' },
            { meta_key: 'consultant-image', meta_value: 'id' },
            { meta_key: 'consultant-name', meta_value: '名前' },
            { meta_key: 'consultant-kana', meta_value: 'なまえ' }
          ].map { |attrs| Wordpress::WpPostmetum.new(attrs) }
        )
        allow_any_instance_of(Wordpress::WorkstyleDecorator).to receive(:consultant_image).and_return('http://example.com/')
      end

      around do |example|
        Bullet.add_safelist type: :unused_eager_loading, class_name: 'Wordpress::Workstyle', association: :wp_postmeta
        example.run
        Bullet.reset_safelist
      end

      it do
        is_expected.to have_title('(test) プロフェッショナリズム | ～新しい働き方を語る～ | フリーコンサルタント.jp')
          .and(satisfy { |doc| doc.find('meta[name=description]', visible: false)[:content] == '概要' })
          .and(satisfy { |doc| doc.find('meta[name=keywords]', visible: false)[:content] == 'キーワード' })
          .and(satisfy { |doc| doc.find('meta[property="og:type"]', visible: false)[:content] == 'article' })
          .and(satisfy { |doc| doc.find('meta[property="og:title"]', visible: false)[:content] == 'タイトル｜プロフェッショナリズム' })
          .and(satisfy { |doc| doc.find('meta[property="og:site_name"]', visible: false)[:content] == 'フリーコンサルタント.jp' })
          .and(satisfy { |doc| doc.find('meta[property="og:url"]', visible: false)[:content] == url_for(model) })
          .and(satisfy { |doc| doc.find('meta[property="og:image"]', visible: false)[:content] == 'http://example.com/' })
          .and(satisfy { |doc| doc.find('meta[property="og:description"]', visible: false)[:content] == '名前（なまえ） 概要' })
      end
    end
  end
end
