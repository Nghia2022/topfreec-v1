# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content::Workstyle', type: :system, js: true do
  describe 'pagerizer' do
    let(:model) { Wordpress::Workstyle }
    let(:contents_url) { content_workstyles_url }
    let(:contents_path) { content_workstyles_path }
    let(:content_name) { 'workstyle' }

    include_examples 'pagerizer'
  end
end
