# frozen_string_literal: true

class Content::BusinessColumnsController < Content::ApplicationController
  before_action :set_header_options

  def index; end

  def show
    render layout: 'welcome'
  end

  private

  def tag_param
    params.fetch(:bccat, nil)
  end

  def column
    @column ||= Wordpress::BusinessColumn.find_by!(post_name: params[:id]).decorate
  end

  def column_scope
    @column_scope ||= Wordpress::BusinessColumn.latest_order
  end

  def business_columns
    @business_columns ||= column_scope.with_term_slug(tag_param)
                                      .patch_cache_key
                                      .page(page_param)
                                      .per(15)
  end

  def latest_contents
    @latest_contents ||= column_scope.patch_cache_key
                                     .limit(3)
  end

  def column_tags
    @column_tags ||= cache('wordpress/wp_term/business_column_cat') do
      Wordpress::WpTerm.with_taxonomy(:business_column_cat).load
    end
  end

  helper_method :column, :business_columns, :latest_contents
  helper_method :column_tags, :tag_param

  concerning :Breadcrumbs do
    def build_breadcrumbs(options)
      add_breadcrumb 'TOP', :root_path
      add_breadcrumb 'ビジネスコラム', :corp_business_columns_path

      case options[:template]
      when 'show'
        add_breadcrumb column.post_title, ''
      end
    end
  end

  concerning :Meta do
    protected

    def build_meta(options)
      case options[:template]
      when 'show'
        build_meta_for_show
      else
        super
      end
    end

    def build_meta_for_show
      set_meta_tags cached_meta_for_show
    end

    def cached_meta_for_show
      cache [:meta, column.cache_key_with_version] do
        [
          meta_for_show_of_base,
          meta_for_show_of_og
        ].inject(:merge)
      end
    end

    def meta_for_show_of_base
      {
        title:       column.post_title,
        site:        default_meta[:site],
        reverse:     true,
        separator:   '|',
        description: column.meta_description,
        keywords:    column.meta_keywords
      }
    end

    def meta_for_show_of_og
      {
        og: {
          type:        'article',
          title:       column.og_title,
          site_name:   default_meta[:site],
          url:         url_for(column),
          image:       column.thumbnail,
          description: column.og_description
        }
      }
    end
  end

  def set_header_options
    header_options[:action] = :corp_top
  end
end
