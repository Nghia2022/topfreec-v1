# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Doorkeeper', type: :config do
  describe 'config' do
    describe '.access_token_class' do
      it do
        expect(Doorkeeper.config.access_token_class).to eq 'Oauth::AccessToken'
      end
    end

    describe '.application_class' do
      it do
        expect(Doorkeeper.config.application_class).to eq 'Oauth::Application'
      end
    end

    describe '.after_successful_authorization' do
      it do
        controller = instance_double('controller')
        token = instance_double('token')
        code = instance_double('auth', token:)
        auth = instance_double('Doorkeeper::OAuth::CodeResponse', auth: code, is_a?: true)

        ctx = instance_double('context', auth:)

        allow(token).to receive(:save_commmune_login_datetime).and_return(true)

        Doorkeeper.config.after_successful_authorization.call(controller, ctx)

        expect(token).to have_received(:save_commmune_login_datetime).once
      end
    end

    describe '.client_credentials' do
      it do
        expect(Doorkeeper.config.client_credentials_methods).to contain_exactly(:from_jwt)
      end
    end

    describe '.token_secret_strategy' do
      it do
        expect(Doorkeeper.config.token_secret_strategy).to eq Doorkeeper::SecretStoring::Sha256Hash
      end
    end

    describe '.authorization_code_expires_in' do
      it do
        expect(Doorkeeper.config.authorization_code_expires_in).to eq 10.minutes
      end
    end

    describe '.optional_scopes' do
      it do
        expect(Doorkeeper.config.optional_scopes).to contain_exactly('openid', 'email')
      end
    end

    describe '.access_token_methods' do
      it do
        expect(Doorkeeper.config.access_token_methods).to contain_exactly(:from_bearer_authorization)
      end
    end

    describe '.handle_auth_errors' do
      it do
        expect(Doorkeeper.config.handle_auth_errors).to eq :raise
      end
    end

    describe '.grant_flows' do
      it do
        expect(Doorkeeper.config.grant_flows).to contain_exactly('authorization_code', 'implicit_oidc')
      end
    end

    describe '.access_token_expires_in' do
      it do
        expect(Doorkeeper.config.access_token_expires_in).to eq 2.hours
      end
    end
  end
end
