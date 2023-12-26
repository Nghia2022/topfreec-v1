# frozen_string_literal: true

FactoryBot.define do
  sequence :sfid do
    "0016F0000A#{SecureRandom.hex(4).upcase}"
  end
end
