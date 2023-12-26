# frozen_string_literal: true

class FilesController < ApplicationController
  layout false

  def show
    return if invalid_aws_credentials?

    fetch_aws_service
  rescue Aws::S3::Errors::NoSuchKey
    render_not_found
  rescue Aws::S3::Errors::ServiceError => e
    log_and_render_service_error(e)
  rescue StandardError => e
    log_and_render_standard_error(e)
  end

  private

  def access_key
    @access_key ||= Rails.application.credentials.dig(:aws, :access_key_id)
  end

  def secret_access_key
    @secret_access_key ||= Rails.application.credentials.dig(:aws, :secret_access_key)
  end

  def region
    @region ||= Rails.application.credentials.dig(:aws, :region)
  end

  def bucket_name
    @bucket_name ||= Rails.application.credentials.dig(:aws, :bucket)
  end

  def invalid_aws_credentials?
    valid_aws_credentials = access_key.present? && secret_access_key.present? && region.present?
    return false if valid_aws_credentials

    render(status: :bad_request)
  end

  def fetch_aws_service
    s3_key = "#{params[:folder]}/#{params[:slug]}"

    credentials = Aws::Credentials.new(access_key, secret_access_key)
    s3_client = Aws::S3::Client.new(
      region:,
      credentials:
    )
    @html_content = s3_client.get_object(bucket: bucket_name, key: s3_key).body.read
  end

  def render_not_found
    Rails.logger.error("AWS S3 Service Error: This file HTML doesn't")
    render status: :not_found
  end

  def log_and_render_service_error(exception)
    Rails.logger.error("AWS S3 Service Error: #{exception.message}")
    render status: :service_unavailable
  end

  def log_and_render_standard_error(exception)
    Rails.logger.error("Standard Error: #{exception.message}")
    render status: :service_unavailable
  end
end
