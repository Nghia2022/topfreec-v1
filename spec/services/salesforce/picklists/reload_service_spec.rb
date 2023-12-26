# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Salesforce::Picklists::ReloadService, type: :service do
  describe '.call', :vcr do
    context 'when no arguments' do
      subject { described_class.call }

      around do |example|
        VCR.use_cassette('salesforce/picklists/reload/all/success') do
          example.run
        end
      end

      before do
        Salesforce::PicklistValue.delete_all
      end

      it do
        expect do
          subject
        end.to change(Salesforce::PicklistValue, :count).from(0)
          .and change(Contact::DesiredWork, :count).from(0)
          .and change(Contact::ExperiencedWork, :count).from(0)
          .and change(Contact::WorkOption, :count).from(0)
          .and change(Contact::WorkPrefecture1, :count).from(0)
          .and change(Contact::WorkPrefecture2, :count).from(0)
          .and change(Contact::WorkPrefecture3, :count).from(0)
          .and change(Project::ExperienceCategory, :count).from(0)
          .and change(Project::WorkPrefecture, :count).from(0)
      end
    end

    context 'with sobject_name' do
      subject { described_class.call(sobject_name: 'Contact') }

      around do |example|
        VCR.use_cassette('salesforce/picklists/reload/one/success') do
          example.run
        end
      end

      before do
        Salesforce::PicklistValue.delete_all
      end

      it do
        expect do
          subject
        end.to change(Salesforce::PicklistValue, :count).from(0)
          .and change(Contact::DesiredWork, :count).from(0)
          .and change(Contact::ExperiencedWork, :count).from(0)
          .and change(Contact::WorkOption, :count).from(0)
          .and change(Contact::WorkPrefecture1, :count).from(0)
          .and change(Contact::WorkPrefecture2, :count).from(0)
          .and change(Contact::WorkPrefecture3, :count).from(0)
          .and not_change(Project::ExperienceCategory, :count).from(0)
          .and not_change(Project::WorkPrefecture, :count).from(0)
      end
    end
  end
end
