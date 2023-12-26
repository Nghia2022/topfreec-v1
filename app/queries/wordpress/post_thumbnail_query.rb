# frozen_string_literal: true

module Wordpress
  class PostThumbnailQuery
    include Query

    def initialize(post_ids:, relation: Wordpress::Attachment.all, meta_key: 'thunbnail')
      @relation = relation
      @post_ids = post_ids
      @meta_key = meta_key
    end

    attr_reader :relation, :post_ids, :meta_key

    def call
      relation.left_outer_joins(:metum)
              .select(select_columns)
              .where(id: post_ids_from_meta)
              .merge(Wordpress::WpPostmetum.thumbnail(meta_key))
    end

    private

    def attachment_table
      @attachment_table ||= Wordpress::Attachment.arel_table
    end

    def metum_table
      @metum_table ||= Wordpress::WpPostmetum.arel_table
    end

    def select_columns
      [
        attachment_table[Arel.star],
        metum_table[:post_id].as('meta_post_id'),
        metum_table[:meta_key].as('meta_key')
      ]
    end

    def meta_for_posts
      Wordpress::WpPostmetum.thumbnail(meta_key).where(post_id: post_ids)
    end

    def post_ids_from_meta
      meta_for_posts.select(:meta_value)
    end
  end
end
