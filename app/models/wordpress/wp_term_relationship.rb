# frozen_string_literal: true

class Wordpress::WpTermRelationship < ApplicationRecord
  establish_connection :wordpress

  self.table_name = 'wp_term_relationships'

  belongs_to :wp_post, foreign_key: :object_id, inverse_of: :wp_term_relationships
  belongs_to :wp_term_taxonomy, foreign_key: :term_taxonomy_id, inverse_of: :wp_term_relationships
  has_one :wp_term, through: :wp_term_taxonomy
end

# == Schema Information
#
# Table name: wp_term_relationships
#
#  term_order       :integer          default(0), not null
#  object_id        :bigint           default(0), unsigned, not null
#  term_taxonomy_id :bigint           default(0), unsigned, not null
#
# Indexes
#
#  term_taxonomy_id  (term_taxonomy_id)
#
