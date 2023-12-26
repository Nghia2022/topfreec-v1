# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DesiredCondition, type: :model do
  describe 'enumerizes' do
    it do
      is_expected.to enumerize(:company_sizes).in(major: '大手', sme: '中小', venture: 'ベンチャー', startup: 'スタートアップ').with_multiple(true)
    end
  end
end
