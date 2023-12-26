# frozen_string_literal: true

# disable :reek:TooManyMethods
class PagesController < ApplicationController
  layout 'welcome'

  def terms; end

  def nda; end

  def statistics; end

  def support; end

  def service; end

  def staff; end

  def service_flow; end

  def sitemap; end

  def faq; end

  concerning :Breadcrumbs do
    protected

    def build_breadcrumbs(options)
      view = options[:template]
      method = :"build_breadcrumbs_for_#{view}"

      add_breadcrumb 'TOP', :root_path
      send(method, options) if respond_to?(method, true)
    end

    def build_breadcrumbs_for_terms(_options)
      add_breadcrumb 'サービス利用規約と免責事項について'
    end

    def build_breadcrumbs_for_nda(_options)
      add_breadcrumb '機密保持の誓約について'
    end

    def build_breadcrumbs_for_support(_options)
      add_breadcrumb 'サポート', :support_page_path
    end

    def build_breadcrumbs_for_service(_options)
      add_breadcrumb 'サービス紹介', :service_page_path
    end

    def build_breadcrumbs_for_staff(_options)
      add_breadcrumb 'サービス紹介', :service_page_path
      add_breadcrumb 'スタッフ紹介', :staff_page_path
    end

    def build_breadcrumbs_for_service_flow(_options)
      add_breadcrumb 'サービス紹介', :service_page_path
      add_breadcrumb 'サービスの流れ', :service_flow_page_path
    end

    def build_breadcrumbs_for_sitemap(_options)
      add_breadcrumb 'サイトマップ'
    end

    # :nocov:
    def build_breadcrumbs_for_faq(_options)
      add_breadcrumb 'よくある質問'
    end
    # :nocov:
  end
end
