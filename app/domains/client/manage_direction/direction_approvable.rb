# frozen_string_literal: true

module Client::ManageDirection
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
      policy_scope(Client::ManageDirection::Direction.all, policy_scope_class: Mypage::Client::DirectionPolicy::Scope).page(page_param)
    end

    def sf_contact
      @sf_contact ||= current_client_user.contact.to_sobject&.then do |sf_contact|
        ProfileDecorator.decorate(sf_contact)
      end
    end
  end
end
