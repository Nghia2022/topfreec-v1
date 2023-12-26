# frozen_string_literal: true

module ManageDirection
  module DirectionMailerPresenterBuilder
    extend ActiveSupport::Concern

    included do
      private

      attr_reader :direction
    end

    module ClassMethods
      def from_direction(direction)
        new(direction).build
      end
    end

    USER_FIELDS = %w[Id Email LastName FirstName].freeze
    CONTACT_FIELDS = %w[Id Web_LoginEmail__c LastName FirstName].freeze

    def fc_account
      # :nocov:
      direction.project.fc_account&.to_sobject || Restforce::SObject.new
      # :nocov:
    end

    # :nocov:
    def sf_users
      @sf_users ||= Salesforce::User.find_multi(sf_user_ids, USER_FIELDS)
    end
    # :nocov:

    # :reek:DuplicateMethodCall
    # :nocov:
    def sf_user_ids
      [direction.project.mws_gyomusekinin_main_c__c, direction.project.mws_gyomusekinin_sub_c__c].compact
    end
    # :nocov:

    # :nocov:
    def main_mws_user
      @main_mws_user ||= sf_users.find { |user| user.Id == direction.project.mws_gyomusekinin_main_c__c } || Salesforce::User.null
    end
    # :nocov:

    # :nocov:
    def sub_mws_user
      @sub_mws_user ||= sf_users.find { |user| user.Id == direction.project.mws_gyomusekinin_sub_c__c } || Salesforce::User.null
    end
    # :nocov:

    delegate :sanitize_sql_array, to: ActiveRecord::Base

    # :nocov:
    def restforce
      @restforce ||= RestforceFactory.new_client
    end
    # :nocov:
  end
end
