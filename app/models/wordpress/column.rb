# frozen_string_literal: true

class Wordpress::Column < Wordpress::WpPost
  scope :latest_order, -> { order(post_date: :desc) }

  def prev_content
    @prev_content ||= Wordpress::Column.published.latest_order.find_by('post_date < ?', post_date)
  end

  def next_content
    @next_content ||= Wordpress::Column.published.latest_order.where('post_date > ?', post_date).last
  end

  def to_param
    post_name
  end

  class << self
    def policy_class
      Content::ColumnPolicy
    end

    # :nocov:
    def tags(key)
      items = [{ key: nil, name: 'すべて', class: 'btn btn-type05 w-auto sp-mt10' }]
      Wordpress::WpTerm.with_taxonomy(:categ).each do |term|
        items.push({ key: term.slug, name: term.name, class: 'btn btn-type05 w-auto sp-mt10' })
      end
      items.each do |item|
        item[:selected] = item[:key] == key
      end
    end
    # :nocov:

    def model_name
      ActiveModel::Name.new(self, nil, 'content_column')
    end

    def decorator_class
      Wordpress::ColumnDecorator
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
