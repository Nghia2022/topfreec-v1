# frozen_string_literal: true

module LeftToEndOfMonthModifier
  def left=(newval)
    newval[3] = 1 if newval.is_a?(Hash)
    super
    _write_attribute('left', left.presence && left.end_of_month)
  end
end
