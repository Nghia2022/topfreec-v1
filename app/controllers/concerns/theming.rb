# frozen_string_literal: true

module Theming
  extend ActiveSupport::Concern

  included do
    before_action :set_theme
  end

  def set_theme
    request.variant = :v2022 if FeatureSwitch.enabled? 'theme_v2022'
  end
end
