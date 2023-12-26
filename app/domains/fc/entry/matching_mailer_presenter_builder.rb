# frozen_string_literal: true

module Fc::Entry
  class MatchingMailerPresenterBuilder
    USER_FIELDS = %w[Id Email LastName FirstName].freeze

    class << self
      def from_matching(matching)
        new(matching).build
      end
    end

    def initialize(matching)
      @matching = matching
    end

    def build
      MatchingMailerPresenter.new(
        matching:,
        contact:  ProfileDecorator.decorate(contact),
        mws_user:,
        project:
      )
    end

    private

    attr_reader :matching

    def contact
      matching.account.person.to_sobject
    end

    def mws_user
      Salesforce::User.find(matching.project.ownerid, USER_FIELDS) || Salesforce::User.null
    end

    def project
      matching.project.decorate
    end
  end
end
