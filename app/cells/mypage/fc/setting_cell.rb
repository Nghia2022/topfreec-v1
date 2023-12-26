# frozen_string_literal: true

class Mypage::Fc::SettingCell < ApplicationCell
  def show
    render
  end

  def general
    cell(Mypage::Fc::Profiles::GeneralCell, model, upload_profile_image: true, edit_button: true).call(:show) if current_user.fc?
  end

  def detail
    render if current_user.fc?
  end

  def project_request
    @project_request ||= Fc::Settings::ProjectRequestForm.new_from_contact(person)
  end

  def last_resume_uploaded_at
    @last_resume_uploaded_at ||= Fc::EditProfile::ResumeForm.last_uploaded_at(account.sfid)
  end

  def qualification
    @qualification ||= person.decorate
  end

  def notice_for_resume
    options[:notice_for_resume]
  end

  def account
    @account ||= current_user.account
  end

  delegate :person, to: :current_user, allow_nil: true
end
