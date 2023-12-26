# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Files', type: :request do
  let(:aws_credentials) do
    {
      aws: {
        access_key_id:     'test_access_key',
        secret_access_key: 'test_secret_key',
        region:            'ap-northeast-1',
        bucket:            'fcweb001',
        folder:            'static'
      }
    }
  end

  before do
    allow(Rails.application).to receive(:credentials).and_return(aws_credentials)
  end

  describe 'GET /:folder/:slug' do
    let(:region) { 'ap-northeast-1' }
    let(:bucket) { 'fcweb001' }
    let(:folder) { 'static' }
    let(:slug) { 'file_1.html' }

    context 'when AWS credentials are valid' do
      before do
        stub_request(:get, "https://#{bucket}.s3.#{region}.amazonaws.com/#{folder}/#{slug}")
          .to_return(status: 200, body: '<html>content</html>', headers: {})
        get "/#{folder}/#{slug}"
      end

      it 'renders the HTML content' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq('<html>content</html>')
      end
    end

    context 'when AWS credentials access_key_id are invalid' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:aws, :access_key_id).and_return(nil)
        stub_request(:get, "https://#{bucket}.s3.#{region}.amazonaws.com/#{folder}/#{slug}")
          .to_return(status: 403, body: '', headers: {})
        get "/#{folder}/#{slug}"
      end

      it 'returns bad request status' do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when AWS credentials secret_access_key are invalid' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:aws, :access_key_id).and_return('test_access_key')
        allow(Rails.application.credentials).to receive(:dig).with(:aws, :secret_access_key).and_return(nil)
        stub_request(:get, "https://#{bucket}.s3.#{region}.amazonaws.com/#{folder}/#{slug}")
          .to_return(status: 403, body: '', headers: {})
        get "/#{folder}/#{slug}"
      end

      it 'returns bad request status' do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when AWS credentials region are invalid' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:aws, :access_key_id).and_return('test_access_key')
        allow(Rails.application.credentials).to receive(:dig).with(:aws, :secret_access_key).and_return('test_secret_key')
        allow(Rails.application.credentials).to receive(:dig).with(:aws, :region).and_return(nil)
        stub_request(:get, "https://#{bucket}.s3.#{region}.amazonaws.com/#{folder}/#{slug}")
          .to_return(status: 403, body: '', headers: {})
        get "/#{folder}/#{slug}"
      end

      it 'returns bad request status' do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when AWS credentials are invalid and return status 503' do
      before do
        stub_request(:get, "https://#{bucket}.s3.#{region}.amazonaws.com/#{folder}/#{slug}")
          .to_return(status: 503, body: '', headers: {})
        get "/#{folder}/#{slug}"
      end

      it 'renders the not found' do
        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end
end
