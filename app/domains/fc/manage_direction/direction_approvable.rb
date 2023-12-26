# frozen_string_literal: true

module Fc::ManageDirection
  module DirectionApprovable
    extend ActiveSupport::Concern

    included do
      helper_method :direction
    end

    private

    def direction
      @direction ||= direction_scope.find(params[:direction_id])
    end

    def direction_scope
      policy_scope(Direction.all, policy_scope_class: Mypage::Fc::DirectionPolicy::Scope)
    end

    def sf_contact
      @sf_contact ||= current_fc_user.contact.to_sobject&.then do |sf_contact|
        ProfileDecorator.decorate(sf_contact)
      end
    end
  end
end
