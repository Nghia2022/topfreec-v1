# frozen_string_literal: true

class Mypage::Fc::ProfilesController < Mypage::Fc::BaseController
  before_action :authorize_resource

  def show
    redirect_to :mypage_fc_settings
  end

  private

  def authorize_resource
    authorize nil, policy_class: Mypage::Fc::ProfilePolicy # TODO: 認可対象のオブジェクトをセットする
  end

  delegate :person, to: :fc_user, allow_nil: true
  delegate :account, to: :person, allow_nil: true
end
