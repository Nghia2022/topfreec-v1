# frozen_string_literal: true

class WorkCategory < ApplicationRecord
  include SalesforceHelpers
  self.table_name = 'salesforce.experiencesubcatergory__c'
  self.sobject_name = 'ExperienceSubCatergory__c'

  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :project_category_meta, foreign_key: :work_category_main, primary_key: :main_category, inverse_of: :work_category
  # rubocop:enable Rails/HasManyOrHasOneDependent

  serialize :experiencesubcatergory__c, MultiplePicklist

  alias_attribute :main_category, :experiencemaincatergory__c
  alias_attribute :sub_category, :experiencesubcatergory__c

  class << self
    def group_sub_categories(sub_categories)
      return {} unless sub_categories.instance_of?(Array)

      filterd_sub_categories = sub_category_mapping.filter { |key, _val| sub_categories.include?(key) }
      filterd_sub_categories.each_key.group_by { |key| filterd_sub_categories[key] }
    end

    private

    def sub_category_mapping
      WorkCategory.order(:name).pluck(:main_category, :sub_category)
                  .map { |main, sub| sub.product([main]).to_h }
                  .inject(:merge)
    end
  end
end

# == Schema Information
#
# Table name: salesforce.experiencesubcatergory__c
#
#  id                         :integer          not null, primary key
#  _hc_err                    :text
#  _hc_lastop                 :string(32)
#  createddate                :datetime
#  experiencemaincatergory__c :string(255)
#  experiencesubcatergory__c  :string(4099)
#  isdeleted                  :boolean
#  name                       :string(80)
#  sfid                       :string(18)
#  systemmodstamp             :datetime
#
# Indexes
#
#  hc_idx_experiencesubcatergory__c_systemmodstamp  (systemmodstamp)
#  hcu_idx_experiencesubcatergory__c_sfid           (sfid) UNIQUE
#
