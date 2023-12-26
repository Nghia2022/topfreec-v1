# frozen_string_literal: true

class LandingPages::RegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend Enumerize

  attribute :email, :string
  attribute :last_name, :string
  attribute :first_name, :string
  attribute :last_name_kana, :string
  attribute :first_name_kana, :string
  attribute :phone, :string
  attribute :work_area1, :string
  attribute :work_area2, :string
  attribute :work_area3, :string
  attribute :landing_page
  attribute :request

  VALID_PHONE_REGEX = /\A\d{10,11}\z/

  validates :email, presence: true
  validate :email_uniqueness_in_fc_user
  validates :last_name, presence: true
  validates :first_name, presence: true
  validates :last_name_kana, presence: true
  validates :first_name_kana, presence: true
  validates :phone, presence: true, format: { with: VALID_PHONE_REGEX, if: :phone? }

  validates :work_area1, presence: true
  validates :work_area2, absence: { if: -> { work_area1.blank? } }
  validates :work_area3, absence: { if: -> { work_area2.blank? } }

  enumerize :work_area1, in: DesiredCondition::WORK_AREAS, i18n_scope: 'enumerize.desired_condition.work_area'
  enumerize :work_area2, in: DesiredCondition::WORK_AREAS, i18n_scope: 'enumerize.desired_condition.work_area'
  enumerize :work_area3, in: DesiredCondition::WORK_AREAS, i18n_scope: 'enumerize.desired_condition.work_area'

  def save
    fc_user.skip_confirmation_notification!

    return unless valid?

    lead = create_lead_in_salesforce(landing_page, request)
    fc_user.assign_attributes(
      lead_sfid: lead.Id,
      lead_no:   lead.LeadId__c
    )
    fc_user.save
  end

  private

  def phone?
    phone.present?
  end

  def fc_user
    @fc_user ||= LandingPages::FcUser.new(email:)
  end

  def email_uniqueness_in_fc_user
    return unless FcUser.exists?(email:)

    errors.add(:email, :taken)
  end

  def create_lead_in_salesforce(landing_page, request)
    Salesforce::Lead.find_or_create_by(
      salesforce_params
      .merge(landing_page.to_sf_lead_hash)
      .merge(
        Web_Anken_ID__c:                 '',
        LeadSource:                      'WEB',
        user_agent__c:                   user_agent(request),
        AD_EBiS_member_name__c:          request.session.id,
        Career_Declaration_Confirmed__c: true,
        Agreement1__c:                   true,
        Agreement3__c:                   true
      )
    )
  end

  def user_agent(request)
    if request.user_agent.to_s.match?(/iPhone|iPad|iPod|Android/)
      'SP'
    else
      'PC'
    end
  end

  def work_location__c
    res = "1-#{work_area1_text}"
    res += " , 2-#{work_area2_text}" if work_area2.present?
    res += " , 3-#{work_area3_text}" if work_area3.present?
    res
  end

  def salesforce_params
    {
      LastName:        last_name,
      firstName:       first_name,
      Kana_Sei__c:     last_name_kana,
      Kana_Mei__c:     first_name_kana,
      Email:           email,
      Phone:           phone,
      WorkLocation__c: work_location__c
    }
  end
end
