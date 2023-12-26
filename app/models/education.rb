# frozen_string_literal: true

class Education
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include SalesforceHelpers
  include Draper::Decoratable
  extend Enumerize

  self.sobject_name = 'Education__c'

  attribute :sfid, :string
  attribute :school_name, :string
  attribute :school_type, :string
  attribute :department, :string
  attribute :joined, :date
  attribute :left, :date
  attribute :degree, :string
  attribute :degree_name, :string
  attribute :major, :string
  attribute :contact_sfid, :string

  alias_attribute :Id, :sfid
  alias_attribute :id, :sfid
  alias_attribute :School_name__c, :school_name
  alias_attribute :School_type__c, :school_type
  alias_attribute :School_Department__c, :department
  alias_attribute :Start_date__c, :joined
  alias_attribute :End_date__c, :left
  alias_attribute :Degree__c, :degree
  alias_attribute :Degree_name__c, :degree_name
  alias_attribute :Major__c, :major
  alias_attribute :Contact__c, :contact_sfid

  enumerize :school_type, in: %w[大学院 大学 短期大学 専門学校 高校 その他]
  enumerize :degree, in: %w[学士 修士 博士 短期大学士 専門士 高度専門士]

  class << self
    # :nocov:
    def for_contact(contact)
      query = format("SELECT %<fields>s FROM %<object>s WHERE Contact__c = '%<contact_sfid>s' ORDER BY Start_date__c", object: sobject_name, fields: attribute_aliases.except('id').keys.join(', '), contact_sfid: contact.sfid)
      result = restforce.query_all(query)

      result.map do |record|
        from_sobject(record)
      end
    end
    # :nocov:

    # :nocov:
    def from_sobject(sobject)
      new(sobject.slice(*attribute_aliases.keys).to_h)
    end
    # :nocov:

    # :nocov:
    def find(id)
      from_sobject(restforce.find(sobject_name, id))
    end
    # :nocov:
  end
end

# == Schema Information
#
# Table name: educations
#
#  contact_sfid :string
#  degree       :string
#  degree_name  :string
#  department   :string
#  joined       :string
#  left         :string
#  major        :string
#  school_name  :string
#  school_type  :string
#  sfid         :string           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_educations_on_contact_sfid  (contact_sfid)
#
