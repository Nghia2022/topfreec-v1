# frozen_string_literal: true

module Tasks
  class AutoApprovedByFcTask < Task
    class << self
      def new_from_direction(direction, **_options)
        new(subject:       I18n.t(:subject, scope: i18n_scope, **subject_params(direction)),
            status:        :done,
            eigyo_type:    :fc_follow,
            activity_date: Date.current,
            description:   I18n.t(:description, scope: i18n_scope, **description_params(direction)),
            owner_id:      direction.project.mws_gyomusekinin_sub_c__c,
            priority:      :normal,
            whatid:        direction.opportunity__c,
            complete_date: direction.approveddatebyfc__c)
      end

      private

      def subject_params(_direction)
        {}
      end

      def description_params(direction)
        {
          project_name:    direction.project_name,
          direction_month: direction.directionmonth__c
        }
      end
    end
  end
end
