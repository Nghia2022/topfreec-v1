# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::SecretStoring::Plain, type: :model do
  describe '.allows_restoring_secrets?' do
    it do
      expect(described_class.allows_restoring_secrets?).to eq(false)
    end
  end
end
