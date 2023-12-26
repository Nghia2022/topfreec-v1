# frozen_string_literal: true

# :reek:MissingSafeMethod
module Projects::Entry
  class Matching < ActiveType::Record[Matching]
    include Rails.application.routes.url_helpers
    include AfterCommitEverywhere
    include StartTimingAdjustable
    include AccountAttributesStorable

    validates_with EntryValidator

    # :reek:TooManyStatements
    def entry(fc_user, params)
      transaction do
        assign_attributes(params)
        assign_attributes(isactivewebentry__c: true, komento__c: comment)

        close_duplicated_entry!(fc_user)
        save!
        save_account!
        apply_notification(fc_user)
      rescue ActiveRecord::RecordInvalid
        raise ActiveRecord::Rollback
      end

      persisted?
    end

    def apply_notification(recipient)
      remaining = Projects::Entry::Matching.remaining_count(account)
      notification = Notification.new(subject: notification_subject(remaining), link: mypage_fc_entries_path, kind: :matching_remaining)
      transaction do
        recipient.notifications.where(kind: notification.kind).destroy_all
        notification.notify(recipient)
      end
    end

    def self.remaining_count(account)
      Settings.entry_limit - account.matchings.for_entry_count.count
    end

    private

    def notification_subject(remaining)
      I18n.t(remaining.positive? ? :remaining : :limit_exceeded, remaining:, scope: [:notifications, self.class.name.underscore, :subject])
    end

    def comment
      <<~COMMENT
        リリース予定日 #{I18n.l(start_timing_for_save, format: :long) if start_timing}
        最低報酬 #{reward_min.present? ? "#{reward_min}万円以上" : '指定なし'}
        希望報酬 #{reward_desired.present? ? "#{reward_desired}万円" : '指定なし'}
        稼働率 #{occupancy_rate}%
      COMMENT
    end

    # :reek:FeatureEnvy, :reek:TooManyStatements
    def close_duplicated_entry!(fc_user) # rubocop:disable Metrics/AbcSize
      duplicated = project.entries.recommended.may_be_duplicated.find_by(account: fc_user.account)
      return if duplicated.blank?

      key = SecureRandom.base58(15)
      assign_attributes(
        referfrommatching__c:       duplicated.sfid,
        referfromroot__c:           duplicated.root__c.value,
        referfrommatchingstatus__c: duplicated.matching_status__c.value,
        referfrommodifier__c:       duplicated.createdbyid,
        referfromentrydate__c:      duplicated.datelog_entryoffer__c,
        referfromrejumesentdate__c: duplicated.datelog_resumeapply__c,
        matchingkeyid__c:           key
      )

      after_commit do
        duplicated.update!(matching_status__c: :closed_duplicated, refertomatching__r__matchingkeyid__c: key)
      end
    end
  end
end

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
