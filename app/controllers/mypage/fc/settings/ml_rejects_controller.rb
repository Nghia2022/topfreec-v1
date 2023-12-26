# frozen_string_literal: true

class Mypage::Fc::Settings::MlRejectsController < Mypage::Fc::BaseController
  before_action :authorize_resource

  def edit
    render (person.ml_reject__c? ? :enable : :disable), layout: 'modal'
  end

  def update
    if person.update(ml_reject__c: false)
      head :no_content
    else
      render :disable, layout: 'modal', status: :unprocessable_entity
    end
  end

  def destroy
    if person.update(ml_reject__c: true)
      head :no_content
    else
      render :enable, layout: 'modal', status: :unprocessable_entity
    end
  end

  private

  def person
    @person ||= current_fc_user.person
  end

  def authorize_resource
    authorize person, nil, policy_class: Mypage::Fc::Settings::MlRejectPolicy
  end

  helper_method :person
end
