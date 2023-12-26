# frozen_string_literal: true

class Corp::PagesController < ApplicationController
  before_action :set_header_options, only: %i[index performance statistics]

  layout 'welcome'

  def index; end

  def performance; end

  def terms; end

  def statistics; end

  private

  def set_header_options
    header_options[:action] = :corp_top
  end

  concerning :Breadcrumbs do
    protected

    def build_breadcrumbs(options)
      view = options[:template]
      method = :"build_breadcrumbs_for_#{view}"

      add_breadcrumb 'TOP', :corp_root_path
      send(method, options) if respond_to?(method, true)
    end

    def build_breadcrumbs_for_performance(_options)
      add_breadcrumb '取引実績', :corp_performance_page_path
    end

    def build_breadcrumbs_for_terms(_options)
      add_breadcrumb 'サービス利用規約と免責事項について', :corp_terms_page_path
    end

    def build_breadcrumbs_for_statistics(_options)
      add_breadcrumb '登録者内訳', :corp_statistics_page_path
    end
  end
end
