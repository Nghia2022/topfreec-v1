# frozen_string_literal: true

class Projects::EntriesController < ApplicationController
  include ProjectSearchable

  before_action :authenticate_user!
  before_action :authorize_resource, except: %i[thanks]

  def new
    render layout: 'modal'
  end

  def create
    if matching.entry(current_fc_user, create_params)
      head :created, location: thanks_entry_path
    else
      render :new, status: :unprocessable_entity, layout: 'modal'
    end
  end

  def thanks
    render layout: 'projects/application'
  end

  private

  def project
    @project ||= policy_scope(Project).find_by!(project_id: params[:project_id]).decorate
  end

  def matching
    @matching ||= Projects::Entry::Matching.new(account: current_fc_user.account, opportunity__c: project.sfid).tap do |matching|
      matching.assign_attributes(
        project_request.attributes.slice('start_timing', 'reward_min', 'reward_desired', 'occupancy_rate')
      )
    end.decorate
  end

  def authorize_resource
    authorize project, :show?
    authorize matching, policy_class: Projects::EntryPolicy
  end

  def create_params
    permitted_attributes(matching, nil, policy_class: Projects::EntryPolicy)
  end

  def person
    @person ||= current_fc_user.person
  end

  def project_request
    @project_request ||= Fc::Settings::ProjectRequestForm.new_from_contact(person)
  end

  helper_method :project, :matching, :related_projects
end
