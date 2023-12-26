# frozen_string_literal: true

class Mypage::Fc::Profiles::GeneralCell < ApplicationCell
  include EditLinkable

  property :first_name
  property :first_name_kana
  property :last_name
  property :last_name_kana
  property :phone
  property :phone2
  property :prefecture
  property :city
  property :building

  def show
    render
  end

  def edit_button
    render if edit_button?
  end

  def address
    prefecture.to_s + city.to_s
  end

  def zipcode
    model.zipcode&.then do |zipcode|
      zipcode.dup.insert(3, '-')
    end
  end

  delegate :transformed_profile_image, to: :decorated_fc_user

  private

  def profile_image_tag
    image_tag(transformed_profile_image, class: class_names('profile-pic', 'upload-trigger cursor-pointer upload-value': upload?), data: profile_image_data)
  end

  def profile_image_data
    return unless upload?

    {
      action:    mypage_fc_profile_profile_image_path,
      attribute: 'profile_image',
      scope:     :fc_user,
      method:    'PATCH'
    }
  end

  def upload?
    options.fetch(:upload_profile_image, false)
  end

  def edit_button?
    options.fetch(:edit_button, false)
  end
end
