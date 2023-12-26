# frozen_string_literal: true

module Client::ManageDirection
  class DirectionAutoApproveQuery
    include Query

    def initialize(relation: Direction.all, date: Date.current)
      @relation = relation
      @date = date
    end

    attr_reader :relation, :date

    def call
      relation.waiting_for_client
              .where(isapprovedbycl__c: [nil, false])
              .where('autoapprschedule_cl__c <= ?', date)
    end
  end
end
