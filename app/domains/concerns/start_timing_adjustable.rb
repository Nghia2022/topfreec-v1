# frozen_string_literal: true

module StartTimingAdjustable
  def start_timing_for_show
    start_timing && (start_timing + adjust_days)
  end

  def start_timing_for_save
    start_timing && (start_timing - adjust_days)
  end

  # :reek:UtilityFunction
  def adjust_days
    FeatureSwitch.enabled?(:adjust_start_timing) ? 1.day : 0.days
  end
end
