# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_openid_request, class: 'Doorkeeper::OpenidConnect::Request' do
    access_grant { FactoryBot.create(:oauth_access_grant) }
    nonce { 'abc' }
  end
end
