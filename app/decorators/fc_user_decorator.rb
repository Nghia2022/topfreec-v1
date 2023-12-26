# frozen_string_literal: true

class FcUserDecorator < Draper::Decorator
  delegate_all

  def phone_masked
    model.phone_normalized.to_s.gsub(/\d(?=\d{4})/, '*')
  end

  def transformed_profile_image
    default_image = '/assets/images/icon/icon_login_user.svg'
    profile_image.present? ? profile_image.to_s.gsub('/image/upload/', '/image/upload/a_auto/') : default_image
  end

  def waiting_directions_count
    @waiting_directions_count ||= Fc::ManageDirection::Direction.joins(:project).filter_by_status('waiting_for_fc').merge(Project.of_fc_contact(model.contact)).count
  end
end
