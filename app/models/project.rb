# frozen_string_literal: true

class Project < Opportunity
  include SalesforceTimestamp
  include CloudinaryTransformable

  PUBLISHED_STAGE = %w[WIN稼働中 WIN稼働済 LOST].freeze
  TYPES = {
    fc:                'FC事業案件',
    dispatch_contract: '派遣契約案件',
    intern:            '紹介予定案件（大人のインターン）',
    referral:          '紹介予定案件',
    venture:           'ベンチャー案件',
    cn:                'CN案件',
    xc:                'XC案件',
    others:            'その他'
  }.freeze

  serialize :experiencecatergory__c, MultiplePicklist
  serialize :experiencesubcatergory__c, MultiplePicklist
  serialize :work_prefectures__c, MultiplePicklist
  serialize :work_options__c, MultiplePicklist

  belongs_to :client, class_name: 'Account', foreign_key: :accountid, primary_key: :sfid
  belongs_to :fc_account, class_name: 'Account', foreign_key: :fc__c, primary_key: :sfid
  belongs_to :main_fc_contact, class_name: 'Contact', foreign_key: :fc_gyomusekinin_main_new__c, primary_key: :sfid, optional: true
  belongs_to :sub_fc_contact, class_name: 'Contact', foreign_key: :fc_gyomusekinin_sub_new__c, primary_key: :sfid, optional: true
  belongs_to :main_cl_contact, class_name: 'Contact', foreign_key: :cl_gyomusekinin_main_c__c, primary_key: :sfid, optional: true
  belongs_to :sub_cl_contact, class_name: 'Contact', foreign_key: :cl_gyomusekinin_sub_c__c, primary_key: :sfid, optional: true

  has_many :entries, class_name: 'Matching', foreign_key: :opportunity__c, primary_key: :sfid
  has_many :effective_entries, -> { for_entry_history }, class_name: 'Matching', foreign_key: :opportunity__c, primary_key: :sfid
  has_many :directions, foreign_key: :opportunity__c, primary_key: :sfid
  has_one :experience, foreign_key: :opportunity__c, primary_key: :sfid, inverse_of: :project
  has_one :project_daily_page_view
  has_one :project_weekly_page_view
  has_one :project_monthly_page_view

  delegate :email, to: :main_fc_contact, prefix: true, allow_nil: true
  delegate :email, to: :sub_fc_contact, prefix: true, allow_nil: true
  delegate :email, to: :main_cl_contact, prefix: true, allow_nil: true
  delegate :email, to: :sub_cl_contact, prefix: true, allow_nil: true

  # FIXME: 仮で案件名を検索
  scope :with_keyword, ->(keyword) { where('web_projectname__c LIKE ?', "%#{sanitize_sql_like(keyword)}%") if keyword.present? }
  scope :with_compensations, ->(ranges) { ranges.map { |range| where(web_reward_min__c: range) }.inject(:or) if ranges.present? }
  scope :min_compensation, ->(reward) { where('web_reward_min__c >= ?', reward) if reward.present? }
  scope :with_experience_categories, lambda { |categories|
    categories.flat_map { |category| [where('experiencecatergory__c LIKE ?', "#{category}%"), where('experiencecatergory__c LIKE ?', "%;#{category}%")] }.inject(:or) if categories.present?
  }
  scope :with_work_locations, ->(work_locations) { build_work_prefectures_query(work_locations) if work_locations.present? }
  scope :with_work_options, ->(work_options) { work_options.map { |work_option| where('work_options__c LIKE ?', work_option.to_s) }.inject(:or) if work_options.present? }
  scope :with_occupancy_rate_mins, ->(occupancy_rate_mins) { occupancy_rate_mins.map { |occupancy_rate_min| where(web_kado_min__c: occupancy_rate_min) }.inject(:or) if occupancy_rate_mins.present? }
  scope :with_occupancy_rate_maxs, ->(occupancy_rate_maxs) { occupancy_rate_maxs.map { |occupancy_rate_max| where(web_kado_max__c: occupancy_rate_max) }.inject(:or) if occupancy_rate_maxs.present? }
  scope :with_period_from, ->(period_from) { build_period_query(period_from, :from) }
  scope :with_period_to, ->(period_to) { build_period_query(period_to, :to) }
  scope :without_closed, ->(filtered) { where.not(isclosedwebreception__c: true) if filtered }
  scope :without_stopped, lambda { |filtered, user|
    where.not(sfid: Matching.entry_stopped.where(account: user.account).select(:opportunity__c)) if filtered && user&.fc?
  }
  scope :without_entered, lambda { |user|
    where.not(sfid: Matching.effective_for_applied.where(account: user.account).select(:opportunity__c)) if user&.fc?
  }
  scope :sort_compensation, -> { order('web_reward_min__c DESC NULLS LAST') }
  scope :published, -> { where(web_openflag__c: true) }
  scope :latest_order, -> { order('web_publishdatetime__c DESC NULLS LAST') }
  scope :new_arrival, -> { where(created_at: new_arrival_at..).latest_order }
  scope :within_half_year, -> { where(created_at: half_year_ago..).latest_order }
  scope :featured_order, -> { joins(:project_daily_page_view).merge(ProjectDailyPageView.popularity).latest_order }
  scope :browsing_histories_with_user, ->(user) { joins(:impressions).where(impressions: { user_id: user.id, message: user.class_name }).order('impressions.created_at': :desc) }
  scope :of_fc_contact, lambda { |contact|
    [
      where(main_fc_contact: contact),
      where(sub_fc_contact: contact)
    ].inject(:or)
  }
  scope :of_cl_contact, lambda { |contact|
    [
      where(main_cl_contact: contact),
      where(sub_cl_contact: contact)
    ].inject(:or)
  }
  scope :with_publish_datetime, -> { where.not(web_publishdatetime__c: nil) }
  scope :with_main_category, ->(main_category) { where('experiencecatergory__c ~ ?', "(^|;)#{Regexp.escape(main_category)}(;|$)") }
  scope :with_sub_category, ->(sub_category) { where('experiencesubcatergory__c ~ ?', "(^|;)#{Regexp.escape(sub_category)}(;|$)") if sub_category.present? }

  enumerize :shouryuu__c, in: { primary: '1', secondary: '2', third: '3', other: '4' }
  enumerize :type, in: TYPES

  cloudinary_transform :web_photo__c, transformations: [:categories]
  cloudinary_transform :web_picture__c, transformations: [:user_profile]

  # FIXME: 仮
  attribute :intern__c, :boolean

  alias_attribute :project_id, :ankenid2__c
  alias_attribute :published, :web_openflag__c
  alias_attribute :main_category, :experiencecatergory__c
  alias_attribute :sub_category, :experiencesubcatergory__c

  is_impressionable

  def manager?(user)
    [fc_gyomusekinin_main_new__c, fc_gyomusekinin_sub_new__c].include? user.contact_sfid
  end

  def owner?(user)
    [cl_gyomusekinin_main_c__c, cl_gyomusekinin_sub_c__c].include? user.contact_sfid
  end

  # :nocov:
  def direction_client_recipients
    [
      main_cl_contact_email,
      sub_cl_contact_email
    ].compact
  end
  # :nocov:

  # :nocov:
  def direction_fc_recipients
    [
      main_fc_contact_email,
      sub_fc_contact_email
    ].compact
  end
  # :nocov:

  def direction_fc_notification_recipients
    [
      main_fc_contact&.fc_user,
      sub_fc_contact&.fc_user
    ].compact
  end

  def to_param
    ankenid2__c
  end

  def entry_exists?(fc_user)
    effective_entries.exists?(account: fc_user.account)
  end

  def entry_stopped?(fc_user)
    entries.entry_stopped.exists?(account: fc_user.account)
  end

  class << self
    def new_arrival_at
      1.month.ago.beginning_of_day
    end

    def half_year_ago
      6.months.ago.beginning_of_day
    end

    def build_work_prefectures_query(locations)
      locations.flat_map { |location| location_to_prefectures(location) }
      &.map { |prefecture| where('work_prefectures__c LIKE ?', "%#{prefecture}%") }
      &.inject(:or) || all
    end

    def build_period_query(period, type)
      return if period.blank?

      [
        where("web_period_#{type}__c": period),
        where("web_period_#{type}__c": nil)
      ].inject(:or)
    end

    def location_to_prefectures(location)
      {
        'hokkaido' => %w[北海道 青森県 岩手県 宮城県 秋田県 山形県 福島県],
        'kita_kanto' => %w[茨城県 栃木県 群馬県],
        'tokyo_23wards' => %w[東京都23区内],
        'tokyo_others' => %w[東京都23区外],
        'capital_area' => %w[埼玉県 千葉県 神奈川県],
        'chubu' => %w[新潟県 富山県 石川県 福井県 山梨県 長野県 岐阜県 静岡県 愛知県],
        'kinki' => %w[大阪府 京都府 兵庫県 滋賀県 奈良県 三重県 和歌山県],
        'chugoku' => %w[鳥取県 島根県 岡山県 広島県 山口県],
        'shikoku' => %w[徳島県 香川県 愛媛県 高知県],
        'kyushu' => %w[福岡県 佐賀県 長崎県 熊本県 大分県 宮崎県 鹿児島県 沖縄県],
        'japan' => %w[日本全国],
        'overseas' => %w[海外]
      }[location.to_s]
    end
  end
end

# == Schema Information
#
# Table name: salesforce.opportunity
#
#  id                                :integer          not null, primary key
#  _hc_err                           :text
#  _hc_lastop                        :string(32)
#  accountid                         :string(18)
#  ankenid2__c                       :string(255)
#  cl_gyomusekinin_main_c__c         :string(18)
#  cl_gyomusekinin_sub_c__c          :string(18)
#  createddate                       :datetime
#  experiencecatergory__c            :string(4099)
#  experiencesubcatergory__c         :string(4099)
#  fc__c                             :string(18)
#  fc_gyomusekinin_main_new__c       :string(18)
#  fc_gyomusekinin_sub_new__c        :string(18)
#  fcweb_pic__c                      :string(255)
#  gyomu_tytle__c                    :string(255)
#  isclosedwebreception__c           :boolean
#  isdeleted                         :boolean
#  jobposting_isactive__c            :boolean
#  jobposting_joblocationtype__c     :boolean
#  kaishiyoteibi_input__c            :date
#  lastmodifieddate                  :datetime
#  mws_gyomusekinin_main_c__c        :string(18)
#  mws_gyomusekinin_sub_c__c         :string(18)
#  name                              :string(120)
#  owner__user_name__c               :string(255)
#  ownerid                           :string(18)
#  recordtypeid                      :string(18)
#  reward__c                         :float
#  sfid                              :string(18)
#  shouryuu__c                       :string(255)
#  systemmodstamp                    :datetime
#  type                              :string(255)
#  web_background__c                 :string(500)
#  web_clientname__c                 :string(255)
#  web_comment__c                    :string(500)
#  web_expiredatetime__c             :datetime
#  web_human_resource_main__c        :string(500)
#  web_human_resource_sub__c         :string(500)
#  web_joboutline__c                 :string(500)
#  web_kado_max__c                   :string(255)
#  web_kado_min__c                   :string(255)
#  web_kado_note__c                  :string(128)
#  web_openflag__c                   :boolean
#  web_owner_pictureflag__c          :boolean
#  web_period__c                     :string(128)
#  web_period_from__c                :date
#  web_period_to__c                  :date
#  web_photo__c                      :string(255)
#  web_picture__c                    :string(1300)
#  web_place_note__c                 :string(128)
#  web_projectname__c                :string(255)
#  web_projectoutline__c             :string(2000)
#  web_publishdatetime__c            :datetime
#  web_reward_max__c                 :float
#  web_reward_min__c                 :float
#  web_reward_note__c                :string(128)
#  web_schema_basesalary_max__c      :float
#  web_schema_basesalary_min__c      :float
#  web_schema_description__c         :string(1500)
#  web_schema_emptype__c             :string(255)
#  web_schema_region__c              :string(255)
#  web_schema_title__c               :string(255)
#  web_schemaquantitativeunittext__c :string(255)
#  web_status__c                     :string(255)
#  web_workenvironment__c            :string(255)
#  web_worksection__c                :string(255)
#  work_options__c                   :string(4099)
#  work_prefectures__c               :string(4099)
#
# Indexes
#
#  hc_idx_opportunity_accountid                  (accountid)
#  hc_idx_opportunity_experiencecatergory__c     (experiencecatergory__c)
#  hc_idx_opportunity_experiencesubcatergory__c  (experiencesubcatergory__c)
#  hc_idx_opportunity_isclosedwebreception__c    (isclosedwebreception__c)
#  hc_idx_opportunity_lastmodifieddate           (lastmodifieddate)
#  hc_idx_opportunity_ownerid                    (ownerid)
#  hc_idx_opportunity_systemmodstamp             (systemmodstamp)
#  hc_idx_opportunity_web_openflag__c            (web_openflag__c)
#  hc_idx_opportunity_web_reward_min__c          (web_reward_min__c)
#  hcu_idx_opportunity_ankenid2__c               (ankenid2__c) UNIQUE
#  hcu_idx_opportunity_sfid                      (sfid) UNIQUE
#
