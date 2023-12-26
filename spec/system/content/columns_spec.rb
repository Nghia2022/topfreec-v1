# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::Columns', type: :system, js: true do
  describe 'pagerizer' do
    let(:model) { Wordpress::Column }
    let(:contents_url) { content_columns_url }
    let(:contents_path) { content_columns_path }
    let(:content_name) { 'column' }

    include_examples 'pagerizer'
  end
end
