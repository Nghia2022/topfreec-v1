# frozen_string_literal: true

class Mypage::Fc::Profiles::ProfileImagesController < Mypage::Fc::BaseController
  before_action :authenticate_fc_user!
  skip_before_action :verify_registration_completed

  def edit
    render layout: 'modal'
  end

  def update
    if fc_user.update(update_params)
      head :no_content
    else
      render json: fc_user, serializer: ErrorSerializer, status: :unprocessable_entity
    end
  end

  private

  def fc_user
    @fc_user = ActiveType.cast(current_fc_user, Fc::EditProfileImage::FcUser)
  end

  def update_params
    permitted_attributes(current_fc_user, nil, policy_class: Mypage::Fc::Profiles::ProfileImagePolicy)
  end
end
