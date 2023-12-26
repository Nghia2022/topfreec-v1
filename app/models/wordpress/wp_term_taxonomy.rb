# frozen_string_literal: true

class Wordpress::WpTermTaxonomy < ApplicationRecord
  establish_connection :wordpress

  self.table_name = 'wp_term_taxonomy'

  has_many :wp_term_relationships, dependent: :nullify
  belongs_to :wp_term, foreign_key: :term_id, inverse_of: :wp_term_taxonomy
end

# == Schema Information
#
# Table name: wp_term_taxonomy
#
#  count            :bigint           default(0), not null
#  description      :text(4294967295) not null
#  parent           :bigint           default(0), unsigned, not null
#  taxonomy         :string(32)       default(""), not null
#  term_id          :bigint           default(0), unsigned, not null
#  term_taxonomy_id :bigint           unsigned, not null, primary key
#
# Indexes
#
#  taxonomy          (taxonomy)
#  term_id_taxonomy  (term_id,taxonomy) UNIQUE
#
