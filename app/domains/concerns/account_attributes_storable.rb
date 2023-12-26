# frozen_string_literal: true

module AccountAttributesStorable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Dirty

    attribute :start_timing, :date
    attribute :reward_min, :integer
    attribute :reward_desired, :integer
    attribute :occupancy_rate, :integer

    alias_attribute :release_yotei__c, :start_timing
    alias_attribute :saitei_hosyu__c, :reward_min
    alias_attribute :kibo_hosyu__c, :reward_desired
    alias_attribute :kado_ritsu__c, :occupancy_rate

    validates :start_timing, presence: true, future_date: true
    validates :reward_min,
              presence:     true,
              numericality: {
                only_integer:             true,
                greater_than_or_equal_to: 0,
                less_than:                1000,
                allow_blank:              true
              }
    validates :reward_desired,
              presence:     true,
              numericality: {
                greater_than_or_equal_to: 0,
                less_than:                1000,
                allow_blank:              true
              }
    validates :occupancy_rate, presence: true
  end

  private

  def save_account!
    account.assign_attributes(
      **account_attributes,
      release_yotei__c:        start_timing_for_save,
      release_yotei_kakudo__c: '確定'
    )
    touch_fc_status_confimed_date
    account.save!
  end

  def touch_fc_status_confimed_date
    account.kakunin_bi__c = Date.current if account.will_save_change_to_release_yotei__c? || account.will_save_change_to_kibo_hosyu__c?
  end

  def account_attributes
    account_attribute_keys.index_with do |attr|
      public_send(attr)
    end
  end

  def account_attribute_keys
    Account.attribute_names & attribute_aliases.keys
  end
end
