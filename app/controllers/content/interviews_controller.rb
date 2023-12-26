# frozen_string_literal: true

class Content::InterviewsController < ApplicationController
  layout 'welcome'

  before_action :set_header_options

  def index; end

  def show; end

  private

  def interview_scope
    @interview_scope ||= Wordpress::Interview.latest_order
  end

  def interviews
    @interviews ||= interview_scope.patch_cache_key.limit(20)
  end

  def interview
    @interview ||= interview_scope.find(params[:id]).decorate
  end

  def set_header_options
    header_options[:action] = :corp_top
  end

  helper_method :interviews, :interview

  concerning :Breadcrumbs do
    protected

    def build_breadcrumbs(options)
      add_breadcrumb 'TOP', :corp_root_path
      add_breadcrumb '活用事例', :corp_interviews_path

      case options[:template]
      when :show
        # :nocov:
        add_breadcrumb '活用事例'
        # :nocov:
      end
    end
  end
end
