# frozen_string_literal: true

class Admin::WelcomeController < Admin::ApplicationController
  skip_before_action :authenticate_admin!, only: %i[index]

  def index; end
end
