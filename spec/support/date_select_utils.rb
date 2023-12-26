# frozen_string_literal: true

module DateSelectUtils
  # disable :reek:UtilityFunction
  def date_select_attributes(name, date)
    date.to_date.strftime('%Y %m %d').split.map.with_index(1) do |val, index|
      ["#{name}(#{index}i)", val]
    end.to_h
  end
end

RSpec.configure do |config|
  config.include DateSelectUtils
end
