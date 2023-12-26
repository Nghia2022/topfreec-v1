# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wordpress::WorkstyleDecorator, type: :decorator do
  subject { described_class.new(model) }

  describe 'share URL' do
    let(:model) { FactoryBot.build(:workstyle, post_name: 'test') }

    it_behaves_like 'share_url', CGI.escape('http://test.host/workstyle/test/')
  end

  describe '#workstyle_modified' do
    let(:model) { FactoryBot.build(:workstyle, post_modified: 'Sun, 26 Apr 2020 23:11:22 UTC +00:00') }

    it do
      expect(subject.workstyle_modified).to eq '2020年4月26日(日)'
    end
  end
end
