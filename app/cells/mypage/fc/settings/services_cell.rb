# frozen_string_literal: true

class Mypage::Fc::Settings::ServicesCell < ApplicationCell
  def show
    render layout: 'layout' if render?
  end

  private

  def render?
    current_user.fc?
  end

  def can_ml_reject?
    current_user.fc?
  end

  def contact
    options.fetch(:contact_for_ml_reject, nil)
  end
end
