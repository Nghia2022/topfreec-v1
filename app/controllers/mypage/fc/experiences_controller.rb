# frozen_string_literal: true

# disable :reek:TooManyMethods
class Mypage::Fc::ExperiencesController < Mypage::Fc::BaseController
  before_action :authorize_resources, only: :index

  def index; end

  private

  def experiences
    @experiences ||= current_fc_user.account.experiences.includes(:project).oldest.page(page_param).decorate
  end

  def authorize_resources
    authorize experiences, policy_class: Mypage::Fc::ExperiencePolicy
  end

  helper_method :experiences

  concerning :Breadcrumbs do
    def build_breadcrumbs(_options)
      add_breadcrumb '稼働実績', mypage_fc_experiences_path
    end
  end
end
