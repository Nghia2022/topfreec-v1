# frozen_string_literal: true

class Fc::EditExperience::ExperienceForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveRecord::AttributeMethods::BeforeTypeCast
  include Draper::Decoratable
  extend Enumerize

  attribute :name, :string
  attribute :details_self__c, :string
  attribute :member_amount__c, :string
  attribute :position__c, :string
  attribute :start_date__c, :date
  attribute :end_date__c, :date

  alias_attribute :description, :details_self__c
  alias_attribute :members_num, :member_amount__c
  alias_attribute :role, :position__c
  alias_attribute :joined, :start_date__c
  alias_attribute :left, :end_date__c

  validates :name, presence: true
  validates :description, presence: true
  validates :members_num, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :role, presence: true

  validates_with StartEndDateValidator, start: :joined, start_as_date: :joined, end: :left, end_as_date: :left

  def initialize(attrs = {})
    @persisted = false
    super
  end

  def save(experience)
    if valid?
      experience.assign_attributes(serializable_hash)
      self.persisted = experience.save
    else
      false
    end
  end

  def update(experience)
    if valid?
      self.persisted = experience.update(serializable_hash)
    else
      false
    end
  end

  def serializable_hash
    attributes.keys.index_with { |attr| send(attr) }
  end

  def persisted?
    persisted
  end

  module LeftModifier
    def left=(newval)
      newval[3] = 1 if newval.is_a?(Hash)
      super
      attr = self.class.attribute_aliases['left']
      _write_attribute(attr, left.presence && left.end_of_month)
    end
  end

  prepend LeftModifier

  delegate :options_for_joined, :options_for_left, to: :class

  private

  attr_writer :persisted

  def persisted
    @persisted ||= false
  end
end
