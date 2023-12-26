# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::AccessGrant, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:fc_user) }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:contact).to(:fc_user) }
    it { is_expected.to delegate_method(:save_commmune_login_datetime).to(:contact) }
  end
end

# == Schema Information
#
# Table name: oauth_access_grants
#
#  id                    :bigint           not null, primary key
#  code_challenge        :string
#  code_challenge_method :string
#  expires_in            :integer          not null
#  redirect_uri          :text             not null
#  revoked_at            :datetime
#  scopes                :string           default(""), not null
#  token                 :string           not null
#  created_at            :datetime         not null
#  application_id        :bigint           not null
#  resource_owner_id     :bigint           not null
#
# Indexes
#
#  index_oauth_access_grants_on_application_id     (application_id)
#  index_oauth_access_grants_on_resource_owner_id  (resource_owner_id)
#  index_oauth_access_grants_on_token              (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (application_id => oauth_applications.id)
#  fk_rails_...  (resource_owner_id => fc_users.id)
#
