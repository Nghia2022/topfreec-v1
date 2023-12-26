# frozen_string_literal: true

class Mypage::Fc::DirectionCell < ApplicationCell
  def show
    render
  end

  private

  def tabs
    %w[all waiting_for_fc completed rejected]
  end

  def tab_class(tab)
    class_names('btn bs-small',
                'btn-theme-02':         filter == tab,
                'btn-theme-02-outline': filter != tab)
  end

  def tab_label(tab)
    I18n.t(tab.presence || :waiting_for_fc, scope: 'enumerize.fc/manage_direction/direction.tabs')
  end

  def filter
    options[:filter] || 'waiting_for_fc'
  end
end
