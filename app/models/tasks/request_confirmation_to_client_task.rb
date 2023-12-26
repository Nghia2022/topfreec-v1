# frozen_string_literal: true

module Tasks
  class RequestConfirmationToClientTask < Task
    class << self
      def new_from_direction(direction, **_options)
        new(subject:       I18n.t(:subject, scope: i18n_scope, **subject_params(direction)),
            status:        :done,
            eigyo_type:    :client_follow,
            activity_date: Date.current,
            description:   I18n.t(:description, scope: i18n_scope, **description_params(direction)),
            owner_id:      direction.project.mws_gyomusekinin_sub_c__c,
            priority:      :normal,
            whatid:        direction.opportunity__c)
      end

      private

      def subject_params(direction)
        {
          project_name:    direction.project_name,
          direction_month: direction.directionmonth__c
        }
      end

      def description_params(direction)
        {
          client_fullname: sf_contact(direction).full_name,
          project_name:    direction.project_name,
          direction_month: direction.directionmonth__c
        }
      end

      def sf_contact(direction)
        ProfileDecorator.decorate(direction.project&.main_cl_contact&.to_sobject || Salesforce::Contact.null)
      end
    end
  end
end
