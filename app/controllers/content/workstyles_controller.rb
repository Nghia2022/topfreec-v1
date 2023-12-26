# frozen_string_literal: true

class Content::WorkstylesController < Content::ApplicationController
  def index; end

  def show
    render layout: 'welcome'
  end

  concerning :Breadcrumbs do
    def build_breadcrumbs(options)
      add_breadcrumb 'TOP', :root_path
      add_breadcrumb 'インタビュー', :content_workstyles_path

      case options[:template]
      when 'show'
        add_breadcrumb workstyle.consultant_name, ''
      end
    end
  end

  private

  # :nocov:
  def workstyle_scope
    @workstyle_scope ||= policy_scope(Wordpress::Workstyle).latest_order
  end
  # :nocov:

  def workstyles
    @workstyles ||= workstyle_scope.patch_cache_key
                                   .includes(:wp_postmeta)
                                   .page(page_param)
                                   .per(15)
  end

  # :nocov:
  def workstyle
    @workstyle ||= workstyle_scope.find_by!(post_name: params[:id]).decorate
  end
  # :nocov:

  def latest_contents
    @latest_contents ||= workstyle_scope.patch_cache_key
                                        .includes(:wp_postmeta)
                                        .limit(3)
  end

  helper_method :workstyles, :workstyle, :latest_contents

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
      cache [:meta, workstyle.cache_key_with_version] do
        [
          meta_for_show_of_base,
          meta_for_show_of_og
        ].inject(:merge)
      end
    end

    def meta_for_show_of_base
      {
        title:       'プロフェッショナリズム | ～新しい働き方を語る～',
        site:        default_meta[:site],
        reverse:     true,
        separator:   '|',
        description: workstyle.meta_description,
        keywords:    workstyle.meta_keywords
      }
    end

    def meta_for_show_of_og
      {
        og: {
          type:        'article',
          title:       workstyle.og_title,
          site_name:   default_meta[:site],
          url:         url_for(workstyle),
          image:       workstyle.consultant_image,
          description: workstyle.og_description
        }
      }
    end
  end
end
