# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doorkeeper::ServerPatch, type: :lib do
  subject(:server) do
    class Doorkeeper::Server
      include Doorkeeper::ServerPatch
    end.new(context)
  end

  let(:context) { double :context }
  let(:client_id) { 'client_id' }
  let(:client_secret) { 'client_secret' }
  let(:client_assertion) { 'client_assertion' }
  let(:client_assertion_type) { 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer' }

  describe '.client' do
    context 'when using JWTs for Client Authentication' do
      before do
        allow(server).to receive(:parameters) do
          {
            client_id:,
            client_assertion:,
            client_assertion_type:
          }
        end
        allow(server).to receive(:credentials).and_return({ uid: client_id, secret: client_assertion })
        allow(Doorkeeper::OAuth::Client).to receive(:authenticate)
      end

      it 'authenticate method is called with by_jwt method once' do
        server.client
        expect(Doorkeeper::OAuth::Client).to have_received(:authenticate).with(server.credentials, Doorkeeper.config.application_model.method(:by_jwt)).once
      end
    end

    context 'when not using JWTs for Client Authentication' do
      before do
        allow(server).to receive(:parameters) do
          {
            client_id:,
            client_secret:
          }
        end
        allow(server).to receive(:credentials).and_return({ uid: client_id, secret: client_secret })
        allow(Doorkeeper::OAuth::Client).to receive(:authenticate)
      end

      it 'authenticate method is called without any method once' do
        server.client
        expect(Doorkeeper::OAuth::Client).to have_received(:authenticate).with(server.credentials).once
      end
    end
  end
end
