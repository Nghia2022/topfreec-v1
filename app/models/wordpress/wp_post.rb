# frozen_string_literal: true

class Wordpress::WpPost < ApplicationRecord
  establish_connection :wordpress

  self.table_name = 'wp_posts'
  self.inheritance_column = 'post_type'

  has_many :wp_term_relationships, foreign_key: :object_id, dependent: :nullify, inverse_of: :wp_post
  has_many :terms, through: :wp_term_relationships, source: :wp_term
  has_many :wp_postmeta, foreign_key: :post_id, dependent: :nullify, inverse_of: :wp_post
  belongs_to :metum, class_name: :WpPostmetum, foreign_key: :id, primary_key: :meta_value, inverse_of: :meta_data

  scope :published, -> { where(post_status: :publish) }
  scope :with_draft, -> { where(post_status: %i[draft publish]) }
  scope :draft, -> { where(post_status: :draft) }
  scope :with_term_slug, ->(slug) { slug.presence && joins(:terms).where(wp_terms: { slug: }) }

  SUPPORTED_POST_TYPES = %w[ceo_blog column workstyle staff interview].freeze
  scope :supported_post_types, -> { where(post_type: SUPPORTED_POST_TYPES) }

  def thumbnail
    BatchLoader.for(id).batch do |post_ids, loader|
      Wordpress::PostThumbnailQuery.call(relation: Wordpress::Attachment.all, post_ids:).each do |attachment|
        loader.call(attachment.meta_post_id, attachment)
      end
    end
  end

  def cache_version
    post_modified.utc.to_fs(cache_timestamp_format)
  end

  module CacheKeyPatch
    # :nocov:
    def cache_key(timestamp_column = :post_modified)
      super(timestamp_column)
    end
    # :nocov:

    # :nocov:
    def cache_version(timestamp_column = :post_modified)
      super(timestamp_column)
    end
    # :nocov:
  end

  class << self
    def find_sti_class(type_name)
      "wordpress/#{type_name}".camelize.singularize.constantize
    end

    def sti_name
      name.underscore.split('/').last
    end

    def preload_thumbnails
      current_scope.each(&:thumbnail)
    end

    def patch_cache_key
      extending CacheKeyPatch
    end
  end
end

# == Schema Information
#
# Table name: wp_posts
#
#  ID                    :bigint           unsigned, not null, primary key
#  comment_count         :bigint           default(0), not null
#  comment_status        :string(20)       default("open"), not null
#  guid                  :string(255)      default(""), not null
#  menu_order            :integer          default(0), not null
#  ping_status           :string(20)       default("open"), not null
#  pinged                :text(16777215)   not null
#  post_author           :bigint           default(0), unsigned, not null
#  post_content          :text(4294967295) not null
#  post_content_filtered :text(4294967295) not null
#  post_date             :datetime         default(NULL), not null
#  post_date_gmt         :datetime         default(NULL), not null
#  post_excerpt          :text(16777215)   not null
#  post_mime_type        :string(100)      default(""), not null
#  post_modified         :datetime         default(NULL), not null
#  post_modified_gmt     :datetime         default(NULL), not null
#  post_name             :string(200)      default(""), not null
#  post_parent           :bigint           default(0), unsigned, not null
#  post_password         :string(255)      default(""), not null
#  post_status           :string(20)       default("publish"), not null
#  post_title            :text(16777215)   not null
#  post_type             :string(20)       default("post"), not null
#  to_ping               :text(16777215)   not null
#
# Indexes
#
#  post_author       (post_author)
#  post_name         (post_name)
#  post_parent       (post_parent)
#  type_status_date  (post_type,post_status,post_date,ID)
#
