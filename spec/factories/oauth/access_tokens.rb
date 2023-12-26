# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_access_token, class: 'Oauth::AccessToken' do
    application { association(:oauth_application) }
  end
end

# == Schema Information
#
# Table name: oauth_access_tokens
#
#  id                     :bigint           not null, primary key
#  expires_in             :integer
#  previous_refresh_token :string           default(""), not null
#  refresh_token          :string
#  revoked_at             :datetime
#  scopes                 :string
#  token                  :string           not null
#  created_at             :datetime         not null
#  application_id         :bigint           not null
#  resource_owner_id      :bigint
#
# Indexes
#
#  index_oauth_access_tokens_on_application_id     (application_id)
#  index_oauth_access_tokens_on_refresh_token      (refresh_token) UNIQUE
#  index_oauth_access_tokens_on_resource_owner_id  (resource_owner_id)
#  index_oauth_access_tokens_on_token              (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (application_id => oauth_applications.id)
#  fk_rails_...  (resource_owner_id => fc_users.id)
#
