# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::EditProfile::ResumeForm, type: :model do
  describe 'validations' do
    it do
      is_expected
        .to validate_presence_of(:document)
    end

    context 'file type' do
      subject { Fc::EditProfile::ResumeForm.new(document: fixture_file_upload("resume/#{file}")) }

      context 'with valid file' do
        let(:file) { 'valid.pptx' }

        it { is_expected.to be_valid }
      end

      context 'with invalid file extension' do
        let(:file) { 'invalid.txt' }

        it { is_expected.to be_invalid }
      end

      context 'with invalid file content' do
        let(:file) { 'invalid.pptx' }

        it { is_expected.to be_invalid }
      end

      context 'with large file' do
        let(:file) { 'valid.pptx' }

        before do
          allow(subject.document).to receive(:size).and_return(2.megabytes + 1)
        end

        it { is_expected.to be_invalid }
      end
    end
  end

  describe '#save' do
    before do
      allow(Salesforce::ContentDocument).to receive(:create!).and_return(true)
    end

    context 'when form is valid' do
      let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
      let(:account) { fc_user.account }
      let(:form) { Fc::EditProfile::ResumeForm.new(document: fixture_file_upload('resume/valid.pptx')) }

      it do
        expect do
          form.save(account.sfid)
        end.to change(form, :persisted?).from(false).to(true)
      end
    end
  end
end
