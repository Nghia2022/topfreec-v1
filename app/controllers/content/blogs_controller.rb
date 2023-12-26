# frozen_string_literal: true

class Content::BlogsController < Content::ApplicationController
  def index; end

  def show
    render layout: 'welcome'
  end

  private

  def blog_scope
    @blog_scope ||= policy_scope(Wordpress::CeoBlog).latest_order
  end

  def blogs
    @blogs = blog_scope.patch_cache_key
                       .page(page_param)
                       .per(15)
  end

  def blog
    @blog ||= blog_scope.find(params[:id]).decorate
  end

  def latest_contents
    @latest_contents ||= blog_scope.patch_cache_key
                                   .limit(3)
  end

  helper_method :blogs, :blog, :latest_contents

  concerning :Breadcrumbs do
    def build_breadcrumbs(options)
      add_breadcrumb 'TOP', :root_path
      add_breadcrumb 'ブログ', :content_blogs_path

      case options[:template]
      when 'show'
        add_breadcrumb blog.post_title, ''
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
      cache [:meta, blog.cache_key_with_version] do
        [
          meta_for_show_of_base,
          meta_for_show_of_og
        ].inject(:merge)
      end
    end

    def meta_for_show_of_base
      {
        title:       blog.post_title,
        site:        default_meta[:site],
        reverse:     true,
        separator:   '|',
        description: blog.meta_description,
        keywords:    blog.meta_keywords
      }
    end

    def meta_for_show_of_og
      site = default_meta[:site]

      {
        og: {
          type:        'article',
          title:       blog.og_title(site),
          site_name:   site,
          url:         url_for(blog),
          image:       blog.thumbnail,
          description: blog.og_description
        }
      }
    end
  end
end
