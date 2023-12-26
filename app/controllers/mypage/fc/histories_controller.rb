# frozen_string_literal: true

class Mypage::Fc::HistoriesController < Mypage::Fc::BaseController
  History = Struct.new('FcHistory', :project_name, :project_id, :created_at)
  before_action :set_histories

  def index; end

  private

  def set_histories
    histories = 1.upto(50).map do |id|
      history = History.new
      history.project_name = "Fake Project #{id}"
      history.project_id = id
      history.created_at = Time.current
      history
    end

    @histories = Kaminari.paginate_array(histories).page(page_param)
    authorize @histories, policy_class: Mypage::Fc::HistoryPolicy
  end
end
