# frozen_string_literal: true

class Oauth::AccessGrant < Doorkeeper::AccessGrant
  belongs_to :fc_user, foreign_key: :resource_owner_id, class_name: 'FcUser', inverse_of: :access_tokens
  delegate :contact, to: :fc_user
  delegate :save_commmune_login_datetime, to: :contact
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
