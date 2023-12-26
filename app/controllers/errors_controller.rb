# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'welcome'
  protect_from_forgery except: :show

  # :reek:TooManyStatements
  def show
    status = request.path[%r{(?<=\A/)\d{3}\z}]
    action = Rack::Utils::SYMBOL_TO_STATUS_CODE.key(status.to_i)
    exception = request.env['action_dispatch.exception']
    render_error_for(status, action, exception)
  rescue StandardError => e
    render :internal_server_error, status: :internal_server_error
  end

  # :nocov:
  def not_found
    render status: :not_found
  end
  # :nocov:

  # :nocov:
  def internal_server_error
    render status: :internal_server_error
  end
  # :nocov:

  # :nocov:
  def forbidden
    render status: :forbidden
  end
  # :nocov:

  # :nocov:
  def service_unavailable
    render status: :service_unavailable
  end
  # :nocov:

  private

  # :reek:ManualDispatch
  def render_error_for(status, action, exception)
    if respond_to?(action)
      render(action, status:)
    elsif exception.is_a? ActionController::InvalidAuthenticityToken
      render :invalid_authenticity_token, status: :unprocessable_entity
    else
      render :internal_server_error, status: :internal_server_error
    end
  end
end
