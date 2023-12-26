# frozen_string_literal: true

class JobPostingBlueprint < Blueprinter::Base
  field :context, name: '@context'
  field :schema_type, name: '@type'
  field :title, name: 'title'
  field :description, name: 'description'
  field :date_posted, name: 'datePosted'
  field :valid_through, name: 'validThrough'
  field :employment_type, name: 'employmentType'
  field :hiring_organization, name: 'hiringOrganization'
  field :jobposting_location, name:   'jobLocation',
                              unless: ->(_name, project, _options) { project.job_location_type? }
  field :applicant_location_requirements, name: 'applicantLocationRequirements',
                                          if:   ->(_name, project, _options) { project.job_location_type? }
  field :job_location_type, name: 'jobLocationType',
                            if:   ->(_name, project, _options) { project.job_location_type? }
  field :base_salary, name: 'baseSalary'
end
