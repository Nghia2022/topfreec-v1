# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Restrict access to engines', type: :request do
  subject do
    send_request
    response
  end

  shared_context 'signed in as admin' do
    before do
      inject_session(oauth_email: 'test@ruffnote.com')
    end
  end

  describe 'GET /dev-tools/admin' do
    context 'when signed in as admin' do
      include_context 'signed in as admin'
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when not signed in as admin' do
      it { is_expected.to redirect_to '/admin' }
    end
  end

  describe 'GET /dev-tools/letter_opener' do
    context 'when signed in as admin' do
      include_context 'signed in as admin'
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when not signed in as admin' do
      it { is_expected.to redirect_to '/admin' }
    end
  end

  describe 'GET /dev-tools/flipper' do
    context 'when signed in as admin' do
      include_context 'signed in as admin'
      it { is_expected.to have_http_status(:found) }
    end

    context 'when not signed in as admin' do
      it { is_expected.to redirect_to '/admin' }
    end
  end

  describe 'GET /sidekiq' do
    context 'when signed in as admin' do
      include_context 'signed in as admin'
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when not signed in as admin' do
      it { is_expected.to redirect_to '/admin' }
    end
  end

  describe 'GET /admin/blazer' do
    context 'when signed in as admin' do
      include_context 'signed in as admin'
      it { is_expected.to have_http_status(:ok) }
    end

    context 'when not signed in as admin' do
      it { is_expected.to redirect_to '/admin' }
    end
  end
end
