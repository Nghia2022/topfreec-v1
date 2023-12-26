# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::Topics', :erb, type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  describe 'GET /topics' do
    it { is_expected.to have_http_status(:ok) }

    it do
      expect(response_body).to have_content('News')
        .and have_selector(:testid, 'cells/topic/show')
    end
  end
end
