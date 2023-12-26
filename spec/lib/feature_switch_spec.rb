# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeatureSwitch, type: :lib do
  describe '.enabled' do
    context 'single feature' do
      context 'when enabled' do
        before do
          FeatureSwitch.enable :feature
        end

        it do
          expect(FeatureSwitch).to be_enabled(:feature)
        end
      end

      context 'when disable' do
        before do
          FeatureSwitch.disable :feature
        end

        it do
          expect(FeatureSwitch).to_not be_enabled(:feature)
        end
      end
    end
  end
end
