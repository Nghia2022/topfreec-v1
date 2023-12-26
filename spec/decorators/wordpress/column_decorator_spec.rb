# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wordpress::ColumnDecorator, type: :decorator do
  subject { described_class.new(model) }

  describe '#column_date' do
    let(:model) { FactoryBot.build(:column, post_date: 'Sun, 26 Apr 2020 23:11:22 UTC +00:00') }

    it do
      expect(subject.column_date).to eq '2020年4月26日(日)'
    end
  end

  describe 'share URL' do
    let(:model) { FactoryBot.build(:column, post_name: 'test') }

    it_behaves_like 'share_url', CGI.escape('http://test.host/column/test/')
  end
end
