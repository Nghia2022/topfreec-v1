# frozen_string_literal: true

class ErrorSerializer < ActiveModel::Serializer
  attribute :status
  attribute :details
  attribute :messages

  delegate :details, to: :errors

  def status
    :error
  end

  def messages
    details.keys.index_with do |key|
      errors.full_messages_for(key)
    end
  end

  private

  def errors
    object.errors
  end
end
