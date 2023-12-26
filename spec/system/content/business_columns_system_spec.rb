# frozen_string_literal: true

require 'rails_helper'

RSpec.xdescribe 'Content::BusinessColumns', type: :system, js: true do
  describe 'pagerizer' do
    let(:model) { Wordpress::BusinessColumn }
    let(:contents_url) { corp_business_columns_url }
    let(:contents_path) { corp_business_columns_path }
    let(:content_name) { 'business_column' }

    include_examples 'pagerizer'
  end
end
