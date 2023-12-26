# frozen_string_literal: true

class Task
  include ActiveModel::Model
  include ActiveModel::Attributes
  include SalesforceHelpers
  extend Enumerize

  self.sobject_name = 'Task'

  attribute :subject, :string
  attribute :status, :string
  attribute :eigyo_type, :string
  attribute :activity_date, :date
  attribute :description, :string
  attribute :owner_id, :string
  attribute :priority, :string
  attribute :whatid, :string
  attribute :complete_date, :date

  STATUSES = {
    initial:     '未着手',
    in_progress: '進行中',
    done:        '完了'
  }.freeze

  EIGYO_TYPES = {
    client_follow: 'クライアントフォロー',
    fc_follow:     'FCフォロー'
  }.freeze

  PRIORILTIES = {
    high:   '高',
    normal: '中',
    low:    '低'
  }.freeze

  enumerize :status, in: STATUSES, default: :initial
  enumerize :eigyo_type, in: EIGYO_TYPES
  enumerize :priority, in: PRIORILTIES

  def self.i18n_scope
    [
      :activemodel,
      :tasks,
      model_name.i18n_key
    ]
  end
end
