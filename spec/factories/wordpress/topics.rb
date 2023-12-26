# frozen_string_literal: true

FactoryBot.define do
  factory :wp_topic, class: 'Wordpress::Topic' do
    post_title { '2020/10/05' }
    post_content { "<a href=\"https://mirai-works.co.jp/interview/m037/\" rel=\"noopener noreferrer\" target=\"_blank\">前編：株式会社MOVED　代表取締役　渋谷雄大氏インタビュー『みらいの働き方 ～先進企業インタビュー～』を追加しました。</a>\r\n" }
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
