# frozen_string_literal: true

class CloudinaryTransforms
  include ActiveModel::Model
  include ActiveModel::Serialization
  include CloudinaryHelper

  attr_reader :original, :options

  def initialize(original, options = {})
    @original = original
    @options = options
    define_transformations
  end

  # :nocov:
  def public_id
    cloudinary? && File.basename(original, '.*')
  end
  # :nocov:

  def basename
    original.presence && File.basename(original)
  end

  # :nocov:
  def as_json(_options = {})
    { public_id:, original:, thumbnail: }
  end
  # :nocov:

  private

  def cloudinary?
    original.present? && parsed_url.host == 'res.cloudinary.com' && cloud_name == Cloudinary.config.cloud_name
  rescue URI::InvalidURIError
    # :nocov:
    false
    # :nocov:
  end

  def image?
    Cloudinary::Utils.supported_image_format?(basename)
  end

  def parsed_url
    @parsed_url ||= URI.parse(original)
  end

  def asset_params
    @asset_params ||= begin
      parts = parsed_url.path.split('/')

      {
        cloud_name: parts[1],
        version:    parts[4][1..],
        folder:     parts[5..-2].join('/')
      }
    end
  end

  def cloud_name
    asset_params[:cloud_name]
  end

  def folder
    asset_params[:folder]
  end

  def version
    asset_params[:version]
  end

  def define_transformations
    options.fetch(:transformations, []).each do |transformation|
      define_singleton_method(transformation) do |options = {}|
        if cloudinary? && image?
          cl_image_path([folder, basename].compact_blank.join('/'), { version:, transformation: }.merge(options))
        else
          original
        end
      end
    end
  end
end
