# frozen_string_literal: true

class PasswordExpiredController < Devise::PasswordExpiredController
  layout 'welcome'
end
