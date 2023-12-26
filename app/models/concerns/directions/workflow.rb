# frozen_string_literal: true

module Directions
  module Workflow
    extend ActiveSupport::Concern

    class_methods do
      def notify_direction(method)
        define_method method do |**options|
          DirectionMailer.public_send(method, self, **options).deliver_later
        end
      end

      def publish_task(method, klass = nil)
        define_method "publish_#{method}_task" do |args = {}|
          klass ||= "Tasks::#{method.to_s.camelize}Task".constantize
          ::Tasks::CreateService.call(task: klass.new_from_direction(self, **args))
        end
      end
    end

    included do
      include Rails.application.routes.url_helpers

      notify_direction :notify_confirmation_request_to_client
      notify_direction :notify_confirmation_request_to_fc
      notify_direction :notify_reconfirmation_request_to_client
      notify_direction :notify_modification_request_to_client
      notify_direction :notify_confirmation_completed_to_client
      notify_direction :notify_auto_approved_by_client

      notify_direction :notify_confirmation_completed_to_fc
      notify_direction :notify_modification_request_to_fc
      notify_direction :notify_auto_approved_by_fc

      publish_task :request_confirmation_to_client
      publish_task :approved_by_client
      publish_task :auto_approved_by_client
      publish_task :rejected_by_client
      publish_task :approved_by_fc
      publish_task :auto_approved_by_fc
      publish_task :rejected_by_fc

      prepend AfterCallbacks
      prepend AfterCommitCallbacks
    end

    module AfterCallbacks
      def after_request_confirmation_to_client
        assign_attributes(requestdatetime__c: Time.current, ismailqueue__c: false)
      end

      def after_approved_by_client(sf_contact:, **_options)
        assign_attributes(approveddatebycl__c:    Time.current,
                          isapprovedbycl__c:      true,
                          approverofcl__c:        sf_contact.full_name,
                          autoapprschedule_cl__c: nil,
                          autoapprschedule_fc__c: calc_auto_approve_schedule_for_fc)

        apply_notification(:ready_for_confirmation, project.direction_fc_notification_recipients)
      end

      def after_rejected_by_client(params:, **_options)
        assign_attributes(params)
        assign_attributes(isapprovedbycl__c:      false,
                          changedhistories__c:    append_changed_histories(kind: 'CL修正依頼', time: Time.current, description: params[:new_direction_detail]),
                          autoapprschedule_cl__c: nil)
      end

      def after_auto_approved_by_client
        now = Time.current

        assign_attributes(isapprovedbycl__c:          true,
                          approverofcl__c:            sf_contact_main_cl.full_name,
                          approveddatebycl__c:        now,
                          autoapprschedule_cl__c:     nil,
                          autoapprschedule_fc__c:     calc_auto_approve_schedule_for_fc,
                          autoapproveddatetime_cl__c: now)
      end

      def after_request_reconfirmation_to_client
        assign_attributes(requestdatetime__c:     Time.current,
                          autoapprschedule_cl__c: calc_auto_approve_schedule_for_client,
                          ismailqueue__c:         false)
        # apply_notification(:ready_for_reconfirmation, project.direction_client_notification_recipients) # TODO: クライアントのサイト内通知
      end

      def after_approved_by_fc(sf_contact:, **_options)
        assign_attributes(isapprovedbyfc__c:      true,
                          approveroffc__c:        sf_contact.full_name,
                          approveddatebyfc__c:    Time.current,
                          autoapprschedule_cl__c: nil,
                          autoapprschedule_fc__c: nil)

        apply_notification(:finalized, project.direction_fc_notification_recipients)
      end

      def after_auto_approved_by_fc
        now = Time.current

        assign_attributes(isapprovedbyfc__c:          true,
                          approveroffc__c:            sf_contact_main_fc.full_name,
                          approveddatebyfc__c:        now,
                          autoapprschedule_cl__c:     nil,
                          autoapprschedule_fc__c:     nil,
                          autoapproveddatetime_fc__c: now)
      end

      def after_rejected_by_fc(params:, **_options)
        assign_attributes(params)
        assign_attributes(isapprovedbycl__c:      false,
                          changedhistories__c:    append_changed_histories(kind: 'FCコメント', time: Time.current, description: params[:comment_from_fc]),
                          autoapprschedule_cl__c: nil,
                          autoapprschedule_fc__c: nil)
      end

      def after_finalize_by_mws
        apply_notification(:finalized, project.direction_fc_notification_recipients)
      end

      def calc_auto_approve_schedule_for_client
        Date.current + (autoapprinterval_cl__c || 8).days
      end

      def calc_auto_approve_schedule_for_fc
        Date.current + (autoapprinterval_fc__c || 8).days
      end

      def append_changed_histories(kind:, time:, description:)
        [
          ("#{changedhistories__c}\r\n\r\n" if changedhistories__c?).to_s,
          "[#{kind}：#{I18n.l(time.in_time_zone('Tokyo'))}]",
          "\r\n",
          description
        ].join
      end

      def sf_contact_main_cl
        ProfileDecorator.decorate(project&.main_cl_contact&.to_sobject || Salesforce::Contact.null)
      end

      def sf_contact_main_fc
        ProfileDecorator.decorate(project&.main_fc_contact&.to_sobject || Salesforce::Contact.null)
      end

      def apply_notification(kind, receivers)
        notification = Notification.new(subject: notification_subject(kind), link: mypage_fc_directions_path, kind: :direction_workflow)
        Notification.notify_all(receivers, notification)
      end

      def notification_subject(kind)
        I18n.t(kind, scope: [:notifications, self.class.name.demodulize.underscore, :subject])
      end
    end

    module AfterCommitCallbacks
      def after_commit_request_confirmation_to_client
        notify_confirmation_request_to_client
      end

      def after_commit_request_reconfirmation_to_client
        notify_reconfirmation_request_to_client
      end

      def after_commit_approve_by_client
        notify_confirmation_completed_to_client
        notify_confirmation_request_to_fc
      end

      def after_commit_auto_approve_by_client
        notify_auto_approved_by_client
        notify_confirmation_request_to_fc
      end

      def after_commit_reject_by_client(sf_contact:, **)
        notify_modification_request_to_client(authorizer_of_client_full_name: sf_contact.full_name)
      end

      def after_commit_approve_by_fc
        notify_confirmation_completed_to_fc
      end

      def after_commit_auto_approve_by_fc
        notify_auto_approved_by_fc
      end

      def after_commit_reject_by_fc(sf_contact:, **)
        notify_modification_request_to_fc(modification_requester_of_fc_full_name: sf_contact.full_name)
      end
    end
  end
end
