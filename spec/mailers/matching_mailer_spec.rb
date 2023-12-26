# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchingMailer, type: :mailer do
  let(:matching) { FactoryBot.create(:matching, :with_project, account: contact.account, project_trait: :with_publish_datetime) }
  let(:contact) { FactoryBot.create(:contact, :fc) }
  let(:sf_contact) { FactoryBot.build_stubbed(:sf_contact, :fc) }
  let(:mws_user) { Salesforce::User.new(Email: 'test@example.com') }
  let(:project) { matching.project }

  before do
    allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
    allow_any_instance_of(Restforce::Concerns::API).to receive(:select).and_return(mws_user)
  end

  shared_examples 'notify to fc' do
    it do
      expect(email)
        .to have_subject(I18n.t("mailers.matching_mailer.#{subject_key}.subject", project_id: project.project_id))
        .and deliver_from(Settings.mailer.from)
        .and deliver_to(sf_contact.Web_LoginEmail__c)
        .and cc_to([mws_user.email, Settings.mailer.matching.cc])
    end
  end

  describe '#notify_candidate_to_fc' do
    let(:email) { MatchingMailer.notify_candidate_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_candidate_to_fc }
    end
  end

  describe '#notify_fc_declined_entry_to_fc' do
    let(:email) { MatchingMailer.notify_fc_declined_entry_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_fc_declined_entry_to_fc }
    end
  end

  describe '#notify_not_eligible_for_entry_to_fc' do
    let(:email) { MatchingMailer.notify_not_eligible_for_entry_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_not_eligible_for_entry_to_fc }
    end
  end

  describe '#notify_client_ng_after_resume_submitted_to_fc' do
    let(:email) { MatchingMailer.notify_client_ng_after_resume_submitted_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_client_ng_after_resume_submitted_to_fc }
    end
  end

  describe '#notify_fc_declining_to_fc' do
    let(:email) { MatchingMailer.notify_fc_declining_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_fc_declining_to_fc }
    end
  end

  describe '#notify_fc_declined_after_mtg_to_fc' do
    let(:email) { MatchingMailer.notify_fc_declined_after_mtg_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_fc_declined_after_mtg_to_fc }
    end
  end

  describe '#notify_lost_candidate_to_fc' do
    let(:email) { MatchingMailer.notify_lost_candidate_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_lost_candidate_to_fc }
    end
  end

  describe '#notify_lost_entry_target_to_fc' do
    let(:email) { MatchingMailer.notify_lost_entry_target_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_lost_entry_target_to_fc }
    end
  end

  describe '#notify_lost_entry_completed_to_fc' do
    let(:email) { MatchingMailer.notify_lost_entry_completed_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_lost_entry_completed_to_fc }
    end
  end

  describe '#notify_lost_resume_submitted_to_fc' do
    let(:email) { MatchingMailer.notify_lost_resume_submitted_to_fc(matching) }

    include_examples 'notify to fc' do
      let(:subject_key) { :notify_lost_resume_submitted_to_fc }
    end
  end
end
