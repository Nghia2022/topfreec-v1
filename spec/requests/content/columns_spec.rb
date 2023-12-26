# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::Columns', :erb, type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /column' do
    it { is_expected.to have_http_status(:ok) }

    it do
      expect(subject.body).to have_selector(:testid, 'content/columns/プロ人材向けコラム')
    end

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

  describe 'GET /column/categ/:tag' do
    let(:tag) { 'independent-entrepreneurial' }

    it { is_expected.to have_http_status(:ok) }

    it do
      expect(subject.body).to have_selector(:testid, 'content/columns/独立・起業のノウハウ・ドウハウ')
    end
  end

  describe 'GET /column/:id' do
    let(:model) { FactoryBot.build_stubbed(:column) }
    let(:id) { model.to_param }

    it_behaves_like 'redirect with status moved permanently'
  end

  describe 'GET /column/:id/' do
    let(:model) { FactoryBot.build_stubbed(:column) }
    let(:id) { model.to_param }

    before do
      collection = instance_double('collection',
                                   find_by!:        model,
                                   find_by:         nil,
                                   where:           Wordpress::Column.none,
                                   patch_cache_key: Wordpress::Column.none)
      columns = instance_double('columns', latest_order: collection, order: collection)
      allow(Wordpress::Column).to receive(:published).and_return(columns)
    end

    it { is_expected.to have_http_status(:ok) }

    it do
      expect(subject.body).to have_selector(:testid, 'content/columns/show')
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
        allow_any_instance_of(Wordpress::Column).to receive(:post_title).and_return('タイトル')
        allow_any_instance_of(Wordpress::Column).to receive(:wp_postmeta).and_return(
          [
            { meta_key: 'column-paragraph-body', meta_value: '本文' },
            { meta_key: '_aioseop_keywords', meta_value: 'キーワード' },
            { meta_key: '_aioseop_description', meta_value: '概要' },
            { meta_key: 'thunbnail', meta_value: 'id' }

          ].map { |attrs| Wordpress::WpPostmetum.new(attrs) }
        )
        allow_any_instance_of(Wordpress::ColumnDecorator).to receive(:thumbnail).and_return('http://example.com/')
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
