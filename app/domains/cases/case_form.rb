# frozen_string_literal: true

class Cases::CaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include Draper::Decoratable
  include Confirming
  extend Enumerize

  attribute :SuppliedEmail, :string
  attribute :SuppliedName, :string
  attribute :SuppliedPhone, :string
  attribute :Description, :string
  attribute :Type, :string

  attribute :last_name, :string
  attribute :first_name, :string
  attribute :last_name_kana, :string
  attribute :first_name_kana, :string

  alias_attribute :email, :SuppliedEmail
  alias_attribute :name, :SuppliedName
  alias_attribute :phone, :SuppliedPhone
  alias_attribute :description, :Description
  alias_attribute :case_type, :Type

  attr_accessor :email_confirmation

  DESCRIPTION_MAXIMUM = 1000

  validates :email, presence: true, confirmation: true, length: { maximum: 80 }
  validates :name, length: { maximum: 80, message: 'は合計で%<count>s文字以下で入力してください' }
  validates :phone, length: { maximum: 40 }
  validates :description, presence: true, length: { maximum: DESCRIPTION_MAXIMUM }
  validates :case_type, presence: true

  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :last_name_kana, presence: true
  validates :first_name_kana, presence: true

  enumerize :case_type, in: %w[問題 機能要求 質問]

  def initialize(attrs = {})
    @persisted = false
    super
  end

  # disable :reek:TooManyStatements
  def save
    if valid?
      self.persisted = restforce.create!('Case', serializable_hash)
    else
      false
    end
  rescue Restforce::ResponseError => e
    errors.add(:base, '何らかの問題が発生しました。後ほどお試しください')
    false
  end

  def serializable_hash
    attribute_aliases.to_h { |aliased, origin| [origin, send(aliased)] }
  end

  def persisted?
    persisted
  end

  def name
    "#{last_name} #{first_name} (#{last_name_kana} #{first_name_kana})"
  end

  def serialize
    {
      email:,
      last_name:,
      first_name:,
      last_name_kana:,
      first_name_kana:,
      phone:,
      case_type:,
      description:
    }
  end

  delegate :description_maximum, to: :class

  private

  attr_writer :persisted

  def persisted
    @persisted ||= false
  end

  def restforce
    @restforce ||= RestforceFactory.new_client
  end

  class << self
    def permitted_attributes
      %i[last_name first_name last_name_kana first_name_kana email email_confirmation phone description case_type confirming]
    end

    def description_maximum
      DESCRIPTION_MAXIMUM
    end
  end
end
