# frozen_string_literal: true

module Tasks
  class RejectedByFcTask < Task
    class << self
      def new_from_direction(direction, sf_contact:, **_options)
        new(subject:       I18n.t(:subject, scope: i18n_scope, **subject_params(direction)),
            status:        :done,
            eigyo_type:    :fc_follow,
            activity_date: Date.current,
            description:   I18n.t(:description, scope: i18n_scope, **description_params(direction, sf_contact:)),
            owner_id:      direction.project.mws_gyomusekinin_sub_c__c,
            priority:      :normal,
            whatid:        direction.opportunity__c)
      end

      private

      def subject_params(direction)
        {
          direction_month: direction.directionmonth__c
        }
      end

      def description_params(direction, sf_contact:)
        {
          approver_of_fc:  sf_contact.full_name,
          project_name:    direction.project_name,
          direction_month: direction.directionmonth__c
        }
      end
    end
  end
end
