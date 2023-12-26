# frozen_string_literal: true

class AccountDecorator < Draper::Decorator
  delegate_all

  alias_attribute :available_date, :web_fcweb_available__c
  alias_attribute :last_entry_at, :fcweb_newentrydatetime__c

  def client_name
    object.clientcompanyname__c
  end
end
