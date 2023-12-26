# frozen_string_literal: true

class Opportunity < ApplicationRecord
  include SalesforceHelpers
  include Readonlyable

  self.table_name = 'salesforce.opportunity'
  self.sobject_name = 'Opportunity'
  self.inheritance_column = 'recordtypeid'

  enumerize :recordtypeid, in: { project: '01228000000gvWpAAI' }
  alias_attribute :record_type, :recordtypeid

  class << self
    def find_sti_class(type)
      type_name = recordtypeid.values.find { |value| value == type }
      type_name.to_s.camelize.constantize
    end

    def sti_name
      recordtypeid.values.find { |value| value == name.demodulize.underscore }&.value
    end
  end

  # :nocov:
  def manager?(user)
    user.account.contacts.exists?(sfid: [fc_gyomusekinin_main_new__c, fc_gyomusekinin_sub_new__c])
  end
  # :nocov:
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
