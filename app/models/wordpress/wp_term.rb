# frozen_string_literal: true

class Wordpress::WpTerm < ApplicationRecord
  establish_connection :wordpress

  self.table_name = 'wp_terms'

  has_many :wp_term_taxonomy, foreign_key: :term_id, dependent: :nullify, inverse_of: :wp_term

  scope :with_taxonomy, ->(taxonomy) { joins(:wp_term_taxonomy).where(wp_term_taxonomy: { taxonomy: }) }

  NullObject = Naught.build do |_config|
    def slug
      nil
    end

    def name
      'すべて'
    end
  end

  def self.null
    NullObject.new
  end
end

# == Schema Information
#
# Table name: wp_terms
#
#  name       :string(200)      default(""), not null
#  slug       :string(200)      default(""), not null
#  term_group :bigint           default(0), not null
#  term_order :integer          default(0)
#  term_id    :bigint           unsigned, not null, primary key
#
# Indexes
#
#  name  (name)
#  slug  (slug)
#
