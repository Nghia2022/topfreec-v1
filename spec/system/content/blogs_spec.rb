# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::Blogs', type: :system, js: true do
  describe 'pagerizer' do
    let(:model) { Wordpress::CeoBlog }
    let(:contents_url) { content_blogs_url }
    let(:contents_path) { content_blogs_path }
    let(:content_name) { 'blog' }

    include_examples 'pagerizer'
  end
end
