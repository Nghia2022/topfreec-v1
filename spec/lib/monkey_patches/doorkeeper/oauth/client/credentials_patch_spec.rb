# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doorkeeper::OAuth::Client::CredentialsPatch, type: :lib do
  subject(:klass) do
    Class.new do
      extend Doorkeeper::OAuth::Client::CredentialsPatch
    end
  end

  let(:client_id) { 'some-uid' }
  let(:client_assertion) { 'some-assetion' }

  describe '.from_jwt' do
    it 'returns credentials from parameters with a client_assertion' do
      request = double parameters: { client_id:, client_assertion: }
      uid, secret = klass.from_jwt(request)

      expect(uid).to eq('some-uid')
      expect(secret).to eq('some-assetion')
    end

    it 'is blank when there are no credentials' do
      request = double parameters: {}
      uid, secret = klass.from_jwt(request)

      expect(uid).to be_blank
      expect(secret).to be_blank
    end
  end
end
