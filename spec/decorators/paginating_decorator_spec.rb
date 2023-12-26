# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaginatingDecorator, type: :decorator do
  describe 'delegations' do
    subject { PaginatingDecorator.new [] }

    it { is_expected.to delegate_method(:current_page).to(:object) }
    it { is_expected.to delegate_method(:total_pages).to(:object) }
    it { is_expected.to delegate_method(:limit_value).to(:object) }
    it { is_expected.to delegate_method(:entry_name).to(:object) }
    it { is_expected.to delegate_method(:total_count).to(:object) }
    it { is_expected.to delegate_method(:offset_value).to(:object) }
    it { is_expected.to delegate_method(:last_page?).to(:object) }
  end
end
