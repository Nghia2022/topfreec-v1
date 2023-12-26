# frozen_string_literal: true

class Fc::EditProfile::WorkHistoryForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  prepend LeftToEndOfMonthModifier

  attribute :company, :string
  attribute :status, :string
  attribute :joined, :date
  attribute :left, :date
  attribute :position, :string

  alias_attribute :company_name__c, :company
  alias_attribute :start_date__c, :joined
  alias_attribute :status__c, :status
  alias_attribute :end_date__c, :left
  alias_attribute :position__c, :position

  validates :company, presence: true
  validates :status, presence: true
  validates :joined, presence: true
  validates :left, presence: true, if: :status_unemployed?

  validates_with StartEndDateValidator, start: :joined, start_as_date: :joined, end: :left, end_as_date: :left

  delegate :options_for_joined, :options_for_left, to: :class

  def initialize(attrs = {})
    @persisted = false
    super
  end

  def save(work_history)
    if valid?
      work_history.assign_attributes(serializable_hash)
      self.persisted = work_history.save
    else
      false
    end
  end

  def update(work_history)
    if valid?
      self.persisted = work_history.update(serializable_hash)
    else
      false
    end
  end

  def serializable_hash
    attribute_aliases.keys.index_with { |attr| send(attr) }
  end

  def persisted?
    persisted
  end

  def status_unemployed?
    status == 'unemployed'
  end

  private

  attr_writer :persisted

  def persisted
    @persisted ||= false
  end
end
