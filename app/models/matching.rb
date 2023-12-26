# frozen_string_literal: true

# :reek:TooManyConstants
class Matching < MatchingBase
  include AASM

  belongs_to :account, foreign_key: :fc__c, primary_key: :sfid
  belongs_to :project, foreign_key: :opportunity__c, primary_key: :sfid

  alias_attribute :ng_reason, :ng_reoson_text__c

  STATUSES = {
    candidate:                             '候補',
    entry_target:                          'エントリー対象',
    entry_completed:                       'エントリー打診済',
    fc_declined_entry:                     'FC辞退(CL挨拶前)',
    not_eligible_for_entry:                'エントリー対象外',
    resume_submitted:                      'レジュメ提出済',
    client_ng_after_resume_submitted:      'クライアントNG(レジュメ提出後)',
    mtg_booked:                            'クライアント挨拶調整済',
    fc_declining:                          'FC辞退手続中',
    fc_declined_after_mtg:                 'FC辞退(CL挨拶後)',
    client_ng_after_mtg:                   'クライアントNG(挨拶実施後)',
    offer_contacted:                       'オファー連絡済',
    win:                                   'WIN(マッチング)',
    lost:                                  'LOST(案件クローズ等)',
    fc_declined:                           '候補FC辞退',
    lost_candidate:                        'LOST_候補',
    lost_entry_target:                     'LOST_エントリー対象',
    lost_entry_completed:                  'LOST_エントリー打診済',
    lost_fc_declined_entry:                'LOST_FC辞退(CL挨拶前)',
    lost_not_eligible_for_entry:           'LOST_エントリー対象外',
    lost_resume_submitted:                 'LOST_レジュメ提出済',
    lost_client_ng_after_resume_submitted: 'LOST_クライアントNG(レジュメ提出後)',
    lost_mtg_booked:                       'LOST_クライアント挨拶調整済',
    lost_fc_declining:                     'LOST_FC辞退手続中',
    lost_fc_declined_after_mtg:            'LOST_FC辞退(CL挨拶後)',
    lost_client_ng_after_mtg:              'LOST_クライアントNG(挨拶実施後)',
    lost_offer_contacted:                  'LOST_オファー連絡済',
    closed_duplicated:                     'クローズ_重複',
    cn_web_diagnostic:                     'web診断(CN)',
    cn_first_interview:                    '初回面接(CN)',
    cn_multiple_interviews:                '複数回面接(CN)',
    cn_final_interview:                    '最終面接(CN)',
    cn_offer:                              '内定(CN)',
    cn_offer_accepted:                     '内定承諾(CN)'
  }.freeze
  enumerize :matching_status__c, in: STATUSES, default: :candidate, scope: true

  INEFFECTIVE_STATUSES_FOR_APPLIED = %i[
    lost
    fc_declined
    closed_duplicated
  ].freeze

  INEFFECTIVE_STATUSES_FOR_RECOMMENDED = INEFFECTIVE_STATUSES_FOR_APPLIED + %i[
    candidate
    entry_target
    entry_completed
    fc_declined_entry
    not_eligible_for_entry
    lost_candidate
    lost_entry_target
    lost_entry_completed
    lost_fc_declined_entry
    lost_not_eligible_for_entry
  ].freeze

  MAY_BE_DUPLICATED_STATUSES = %i[
    candidate
    entry_target
    entry_completed
    fc_declined_entry
    not_eligible_for_entry
  ].freeze

  STOPPED_STATUSES = %i[
    lost_candidate
    lost_entry_target
    lost_entry_completed
    lost_fc_declined_entry
    lost_not_eligible_for_entry
    lost_resume_submitted
    lost_client_ng_after_resume_submitted
  ].freeze

  APPLIED_FROM_FC_ROOTES = %i[
    self_recommend_direct
    self_recommend_fcweb
  ].freeze

  NOTIFABLE_WITH_STOP_STATUS_CHANGE_EMAIL = %i[
    fc_declined_entry
    fc_declining
    fc_declined_after_mtg
  ].freeze

  scope :in_progress, -> { where(isactivewebentry__c: true) }
  scope :latest, -> { order(created_at: :desc) }
  scope :with_published_projects, -> { joins(:project).merge(Project.with_publish_datetime) }
  scope :effective_for_applied, -> { applied_from_fc.with_published_projects.where.not(matching_status__c: INEFFECTIVE_STATUSES_FOR_APPLIED) }
  scope :effective_for_recommended, -> { recommended.with_published_projects.where.not(matching_status__c: INEFFECTIVE_STATUSES_FOR_RECOMMENDED) }
  scope :may_be_duplicated, -> { where(matching_status__c: MAY_BE_DUPLICATED_STATUSES) }
  scope :applied_from_fc, -> { where(root__c: APPLIED_FROM_FC_ROOTES) }
  scope :recommended, -> { where.not(root__c: APPLIED_FROM_FC_ROOTES) }
  scope :not_applied_from_fc, -> { where.not(root__c: APPLIED_FROM_FC_ROOTES) }
  scope :for_entry_count, -> { for_entry_history.in_progress }
  scope :for_entry_history, -> { [effective_for_applied, effective_for_recommended].inject(:or) }
  scope :entry_stopped, -> { recommended.where(matching_status__c: STOPPED_STATUSES) }

  ROOTS = {
    recommend_sales:       '営業推薦',
    recommend_colabo:      'COLABO推薦',
    self_recommend_direct: '自己推薦(直連絡)',
    self_recommend_fcweb:  '自己推薦(FCWeb)'
  }.freeze
  enumerize :root__c, in: ROOTS, default: :self_recommend_fcweb

  aasm column: :matching_status__c, enum: true do
    Matching.matching_status__c.each_value do |value|
      state value.to_sym, initial: value == Matching.matching_status__c.default_value
    end

    event :decline do
      transitions(
        from:  %i[candidate entry_target entry_completed],
        to:    :fc_declined_entry,
        guard: :can_decline_immediately?
      )
      transitions(
        from:  %i[candidate entry_target entry_completed],
        to:    :fc_declining,
        guard: %i[cannot_decline_immediately? update_ng_reason?],
        after: :update_ng_reason
      )

      transitions from: %i[resume_submitted mtg_booked], to: :fc_declining, guard: :update_ng_reason?, after: :update_ng_reason
      transitions from: %i[offer_contacted], to: :fc_declined_after_mtg, guard: :update_ng_reason?, after: :update_ng_reason
    end
  end

  # :nocov:
  rails_admin do
    field :id
    field :sfid
    field :_hc_lastop
    field :_hc_err
    field :name
    field :matching_status__c do
      pretty_value do
        value.value
      end
    end
    field :recordtypeid
    field :root__c do
      pretty_value do
        value.value
      end
    end
    field :account
  end
  # :nocov:

  def update_ng_reason(params = {})
    assign_attributes(params.slice(:ng_reason))
  end

  def owner?(user)
    account == user.account
  end

  def update_ng_reason?
    ng_reason?
  end

  def entry?
    candidate? || entry_target? || entry_completed?
  end

  def proposed?
    resume_submitted? || mtg_booked? || offer_contacted?
  end

  def can_decline_immediately?
    entry? && !client_mtg_date__c? && !datelog_resumeapply__c?
  end

  def cannot_decline_immediately?
    !can_decline_immediately?
  end

  def can_decline_with_reason?
    cannot_decline_immediately? && (entry? || proposed?)
  end
end

Matching.enumerized_attributes[:matching_status__c].extend Enumerize::AllowInvalid

# == Schema Information
#
# Table name: salesforce.matching__c
#
#  id                                   :integer          not null, primary key
#  _hc_err                              :text
#  _hc_lastop                           :string(32)
#  client_mtg_date__c                   :date
#  createdbyid                          :string(18)
#  createddate                          :datetime
#  datelog_clfcmtg__c                   :date
#  datelog_entryoffer__c                :date
#  datelog_resumeapply__c               :date
#  fc__c                                :string(18)
#  isactivewebentry__c                  :boolean
#  isdeleted                            :boolean
#  isstopstatuschangemail__c            :boolean
#  komento__c                           :string(255)
#  matching_status__c                   :string(255)
#  matchingkeyid__c                     :string(15)
#  name                                 :string(80)
#  ng_reoson_text__c                    :string(255)
#  opportunity__c                       :string(18)
#  recordtypeid                         :string(18)
#  referfromentrydate__c                :date
#  referfrommatching__c                 :string(18)
#  referfrommatchingstatus__c           :string(128)
#  referfrommodifier__c                 :string(18)
#  referfromrejumesentdate__c           :date
#  referfromroot__c                     :string(128)
#  refertomatching__c                   :string(18)
#  refertomatching__r__matchingkeyid__c :string(15)
#  root__c                              :string(255)
#  sfid                                 :string(18)
#  systemmodstamp                       :datetime
#
# Indexes
#
#  hc_idx_matching__c_fc__c                (fc__c)
#  hc_idx_matching__c_isactivewebentry__c  (isactivewebentry__c)
#  hc_idx_matching__c_opportunity__c       (opportunity__c)
#  hc_idx_matching__c_recordtypeid         (recordtypeid)
#  hc_idx_matching__c_refertomatching__c   (refertomatching__c)
#  hc_idx_matching__c_systemmodstamp       (systemmodstamp)
#  hcu_idx_matching__c_matchingkeyid__c    (matchingkeyid__c) UNIQUE
#  hcu_idx_matching__c_sfid                (sfid) UNIQUE
#
