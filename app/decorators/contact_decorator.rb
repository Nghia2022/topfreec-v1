# frozen_string_literal: true

class ContactDecorator < Draper::Decorator
  delegate_all

  alias_attribute :experienced_works, :experienced_works__c
  alias_attribute :desired_works, :desired_works__c
  alias_attribute :experienced_works_main, :experienced_works_main__c
  alias_attribute :desired_works_main, :desired_works_main__c
  alias_attribute :ml_reject, :ml_reject__c
  alias_attribute :license, :license__c

  # TODO: #3353 Flipperの分岐を無くして1つにする
  def works_to_recommends
    if Flipper.enabled? :new_work_category
      (experienced_works_main.to_a + desired_works_main.to_a).uniq
    else
      (experienced_works.to_a + desired_works.to_a).uniq
    end
  end
end
