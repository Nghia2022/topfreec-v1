# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::Interviews', type: :request do
  subject do
    send_request
    response
  end

  describe 'GET /corp/interview' do
    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'GET /corp/interview/:id' do
    let(:id) { interview.id }

    let(:interview) { FactoryBot.build_stubbed(:interview) }
    let(:profile_meta) { instance_double(Wordpress::WpPostmetum, meta_key: 'interview_profile', meta_value: 'Profile') }

    before do
      interviews = double('interviews')
      allow(Wordpress::Interview).to receive(:latest_order).and_return(interviews)
      allow(interviews).to receive(:find).with(id.to_s).and_return(interview)
      allow(interviews).to receive(:find_by).and_return(nil)
      allow(interview).to receive(:wp_postmeta).and_return([profile_meta])
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end
end
