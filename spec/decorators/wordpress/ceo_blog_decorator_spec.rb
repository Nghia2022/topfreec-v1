# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wordpress::CeoBlogDecorator, type: :decorator do
  subject { described_class.new(model) }

  describe '#blog_date' do
    let(:model) { FactoryBot.build(:ceo_blog, post_date: 'Sun, 26 Apr 2020 23:11:22 UTC +00:00') }

    it do
      expect(subject.blog_date).to eq '2020年4月26日(日)'
    end
  end

  describe '#blog_modified' do
    let(:model) { FactoryBot.build(:ceo_blog, post_modified: 'Sun, 26 Apr 2020 23:11:22 UTC +00:00') }

    it do
      expect(subject.blog_modified).to eq '2020年4月26日(日)'
    end
  end

  describe 'share URL' do
    let(:model) { FactoryBot.build(:ceo_blog, id: 123) }

    it_behaves_like 'share_url', CGI.escape('http://test.host/ceo_blog/123/')
  end
end
