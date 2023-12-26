# frozen_string_literal: true

class Mypage::Fc::Settings::ProjectRequestCell < ApplicationCell
  include EditLinkable

  delegate :start_timing, :reward_min, :reward_desired, to: :model

  def show
    render
  end

  def start_timing_date
    I18n.ln(start_timing.to_date, format: :without_year) if start_timing.present?
  end

  def minimum_reward
    if reward_min.present? && !reward_min.zero?
      "#{reward_min} 万円以上"
    else
      '未回答'
    end
  end

  def desired_reward
    if reward_desired.present? && !reward_desired.zero?
      "#{reward_desired} 万円"
    else
      '未回答'
    end
  end

  def occupancy_rate
    DesiredCondition.occupancy_rate_options.find { |item| item.second == model.occupancy_rate }&.first
  end

  def requests
    text_format model.requests
  end
end
