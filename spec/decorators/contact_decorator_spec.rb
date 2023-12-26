# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactDecorator do
  subject(:decorated) { contact.decorate }
  let(:contact) { FactoryBot.create(:contact, :fc, contact_attributes) }

  describe '#works_to_recommends' do
    subject { decorated.works_to_recommends }

    # TODO: #3353 Flipperの分岐を無くして1つにする
    context 'when the feature flag :new_work_category is true' do
      before do
        Flipper.enable :new_work_category
      end

      let(:experienced_works_main) { WorkCategory.pluck(:main_category).flatten.sample(rand(1..4)) }
      let(:desired_works_main) { WorkCategory.pluck(:main_category).flatten.sample(rand(1..4)) }
      let(:contact_attributes) do
        {
          experienced_works_main__c: experienced_works_main,
          desired_works_main__c:     desired_works_main
        }
      end

      it { is_expected.to eq (experienced_works_main + desired_works_main).uniq }
    end

    context 'when the feature flag :new_work_category is false' do
      subject { decorated.works_to_recommends }

      let(:experienced_works) { Contact::ExperiencedWork.all.map(&:value).sample(rand(1..4)) }
      let(:desired_works) { Contact::DesiredWork.all.map(&:value).sample(rand(1..4)) }
      let(:contact_attributes) do
        {
          experienced_works__c: experienced_works,
          desired_works__c:     desired_works
        }
      end

      it { is_expected.to eq (experienced_works + desired_works).uniq }
    end
  end
end
