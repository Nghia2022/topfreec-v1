# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wordpress::InterviewDecorator do
  subject(:decorated) { described_class.new(model) }
  let(:model) { FactoryBot.build_stubbed(:interview) }

  describe '#thumbnail' do
    subject { decorated.thumbnail }

    let(:thumbnail) { double('thumbnail', __sync: meta) }
    let(:meta) { double('meta', guid: 'guid') }

    before do
      allow(model).to receive(:thumbnail).and_return(thumbnail)
    end

    it do
      is_expected.to eq 'guid'
    end
  end

  describe '#profile' do
    subject { decorated.profile }

    let(:postmeta) { [double('meta', meta_key: 'interview_profile', meta_value: 'Profile')] }

    before do
      allow(model).to receive(:wp_postmeta).and_return(postmeta)
    end

    it do
      is_expected.to eq 'Profile'
    end
  end
end
