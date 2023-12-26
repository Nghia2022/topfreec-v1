# frozen_string_literal: true

class DirectionDecorator < Draper::Decorator
  delegate_all
  decorates_association :project

  delegate :client_name, to: :project

  alias_attribute :status, :status__c
  alias_attribute :direction_month, :directionmonth__c
  alias_attribute :direction_detail, :directiondetail__c

  # FC
  alias_attribute :comment_from_fc, :commentfromfc__c
  alias_attribute :approved_date_by_fc, :approveddatebyfc__c
  alias_attribute :approved_by_fc, :isapprovedbyfc__c
  alias_attribute :approver_of_fc, :approveroffc__c
  alias_attribute :auto_approve_schedule_fc, :autoapprschedule_fc__c

  # CL
  alias_attribute :new_direction_detail, :newdirectiondetail__c
  alias_attribute :approved_date_by_cl, :approveddatebycl__c
  alias_attribute :approved_by_cl, :isapprovedbycl__c
  alias_attribute :approver_of_cl, :approverofcl__c
  alias_attribute :auto_approve_schedule_cl, :autoapprschedule_cl__c

  class << self
    def collection_decorator_class
      Direction::CollectionDecorator
    end
  end
end
