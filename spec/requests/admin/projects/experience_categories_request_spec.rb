# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Projects::ExperienceCategories', type: :request do
  subject do
    send_request
    response
  end

  before do
    inject_session(oauth_email: 'test@ruffnote.com')
  end

  describe 'GET /fcweb-admin-01/projects/experience_categories' do
    it do
      is_expected.to have_http_status(:ok)
    end
  end
end
