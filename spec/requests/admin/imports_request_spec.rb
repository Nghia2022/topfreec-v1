# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Imports', type: :request do
  subject do
    send_request
    response
  end

  before do
    inject_session(oauth_email: 'test@ruffnote.com')
  end

  describe 'GET /fcweb-admin-01/import/new' do
    it { is_expected.to have_http_status(:ok) }
  end

  describe 'POST /fcweb-admin-01/import' do
    context 'with valid params' do
      let(:params) do
        {
          csv: file_fixture('users.csv')
        }
      end
      it { is_expected.to redirect_to(new_admin_import_path) }
      it do
        expect do
          send_request
        end.to change(FcUser, :count).by(1)
      end
      it do
        expect do
          send_request
        end.to change(ClientUser, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:params) do
        {
          csv: 'invalid'
        }
      end
      it { is_expected.to redirect_to(new_admin_import_path) }
      it do
        expect do
          send_request
        end.not_to change(FcUser, :count)
      end
      it do
        expect do
          send_request
        end.not_to change(ClientUser, :count)
      end
    end
  end
end
