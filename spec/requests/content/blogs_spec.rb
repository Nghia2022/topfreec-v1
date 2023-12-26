# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::Blogs', :erb, type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /ceo_blog' do
    it { is_expected.to have_http_status(:ok) }

    it do
      expect(subject.body).to have_selector(:testid, 'content/blogs/index')
    end
  end

  describe 'GET /ceo_blog/:id' do
    let(:model) { FactoryBot.build_stubbed(:ceo_blog) }
    let(:id) { model.to_param }

    it_behaves_like 'redirect with status moved permanently'
  end

  describe 'GET /ceo_blog/:id/' do
    let(:model) { FactoryBot.build_stubbed(:ceo_blog) }
    let(:id) { model.to_param }

    before do
      collection = instance_double('collection',
                                   find:            model,
                                   find_by:         nil,
                                   where:           Wordpress::CeoBlog.none,
                                   patch_cache_key: Wordpress::CeoBlog.none)
      ceo_blogs = instance_double('ceo_blogs', latest_order: collection, order: collection)
      allow(Wordpress::CeoBlog).to receive(:published).and_return(ceo_blogs)
    end

    it { is_expected.to have_http_status(:ok) }

    it do
      expect(subject.body).to have_selector(:testid, 'content/blogs/show')
    end

    describe 'share url' do
      subject do
        send_request
        response.body
      end

      it do
        expect(subject).to have_link(href: "http://www.facebook.com/share.php?u=#{CGI.escape(request.original_url)}")
          .and have_link(href: "https://twitter.com/share?url=#{CGI.escape(request.original_url)}")
          .and have_link(href: "http://b.hatena.ne.jp/add?mode=confirm&url=#{CGI.escape(request.original_url)}")
      end
    end

    describe 'metatags with postmeta' do
      subject do
        send_request
        Capybara.string(response.body)
      end

      let(:thumbnail) { Wordpress::Attachment.new(guid: 'http://example.com/') }

      before do
        allow_any_instance_of(Wordpress::CeoBlog).to receive(:post_title).and_return('タイトル')
        allow_any_instance_of(Wordpress::CeoBlog).to receive(:post_content).and_return('本文')
        allow_any_instance_of(Wordpress::CeoBlog).to receive_message_chain(:thumbnail, :__sync).and_return(thumbnail)
        allow_any_instance_of(Wordpress::CeoBlog).to receive(:wp_postmeta).and_return(
          [
            { meta_key: '_aioseop_keywords', meta_value: 'キーワード' }
          ].map { |attrs| Wordpress::WpPostmetum.new(attrs) }
        )
      end

      it do
        is_expected.to have_title('(test) タイトル | フリーコンサルタント.jp')
          .and(satisfy { |doc| doc.find('meta[name=description]', visible: false)[:content] == '本文' })
          .and(satisfy { |doc| doc.find('meta[name=keywords]', visible: false)[:content] == 'キーワード' })
          .and(satisfy { |doc| doc.find('meta[property="og:type"]', visible: false)[:content] == 'article' })
          .and(satisfy { |doc| doc.find('meta[property="og:title"]', visible: false)[:content] == 'タイトル｜代表ブログ｜フリーコンサルタント.jp' })
          .and(satisfy { |doc| doc.find('meta[property="og:site_name"]', visible: false)[:content] == 'フリーコンサルタント.jp' })
          .and(satisfy { |doc| doc.find('meta[property="og:url"]', visible: false)[:content] == url_for(model) })
          .and(satisfy { |doc| doc.find('meta[property="og:image"]', visible: false)[:content] == 'http://example.com/' })
          .and(satisfy { |doc| doc.find('meta[property="og:description"]', visible: false)[:content] == '本文' })
      end
    end
  end
end
