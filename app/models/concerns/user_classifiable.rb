# frozen_string_literal: true

module UserClassifiable
  extend ActiveSupport::Concern

  delegate :fc?, :fc_company?, to: :account, allow_nil: true
  delegate :client?, to: :account, allow_nil: true

  def wp_user?
    is_a? Wordpress::WpUser
  end
end
