# frozen_string_literal: true

module Projects::Entry
  class EntryValidator < ActiveModel::Validator
    def validate(record)
      record.errors.add(:base, :limit_exceeded, entry_limit: Settings.entry_limit) if record.account.matchings.for_entry_count.count >= Settings.entry_limit
      record.errors.add(:opportunity__c, :taken) if record.account.matchings.for_entry_history.exists?(opportunity__c: record.opportunity__c)
    end
  end
end
