# frozen_string_literal: true

class Mypage::Fc::EmailsController < Mypage::Fc::BaseController
  before_action :set_fc_user

  def edit
    render layout: 'modal'
  end

  def update
    if @fc_user.update(update_params)
      redirect_to mypage_fc_settings_path, notice: '入力頂いたアドレスにメールを送信しました。'
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
    end
  end

  private

  def set_fc_user
    @fc_user = ActiveType.cast(current_user, Fc::EditEmail::FcUser)
    @fc_user.email = nil
    authorize @fc_user, policy_class: Mypage::Fc::EmailPolicy
  end

  def update_params
    permitted_attributes(@fc_user, nil, policy_class: Mypage::Fc::EmailPolicy)
  end
end
