# frozen_string_literal: true

class Wordpress::WpPostmetum < ApplicationRecord
  establish_connection :wordpress

  self.table_name = 'wp_postmeta'

  belongs_to :wp_post, foreign_key: :post_id, inverse_of: :wp_postmeta

  has_one :meta_data, class_name: :WpPost, primary_key: :meta_value, foreign_key: :id, dependent: :nullify, inverse_of: :wp_postmeta

  scope :thumbnail, ->(meta_key = 'thunbnail') { where(meta_key:) }
end

# == Schema Information
#
# Table name: wp_postmeta
#
#  meta_key   :string(255)
#  meta_value :text(4294967295)
#  meta_id    :bigint           unsigned, not null, primary key
#  post_id    :bigint           default(0), unsigned, not null
#
# Indexes
#
#  meta_key  (meta_key)
#  post_id   (post_id)
#
