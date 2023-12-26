# frozen_string_literal: true

module Fc::ManageDirection
  class DirectionAutoApproveQuery
    include Query

    def initialize(relation: Direction.all, date: Date.current)
      @relation = relation
      @date = date
    end

    attr_reader :relation, :date

    def call
      relation.waiting_for_fc
              .where(isapprovedbyfc__c: [nil, false])
              .where('autoapprschedule_fc__c <= ?', date)
    end
  end
end
