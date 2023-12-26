# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_access_grant, class: 'Oauth::AccessGrant' do
    resource_owner_id { FactoryBot.create(:fc_user).id }
    application { FactoryBot.build(:oauth_application) }
    expires_in { 600 }
    redirect_uri { 'https://127.0.0.1/callback' }
    scopes { 'openid email' }
    created_at { Time.current }
    revoked_at { nil }
    code_challenge { '' }
    code_challenge_method { 'S256' }
  end
end
