# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  around do |ex|
    Rails.application.env_config['action_dispatch.show_exceptions'] = true
    Rails.application.env_config['action_dispatch.show_detailed_exceptions'] = false

    ex.run

    Rails.application.env_config['action_dispatch.show_exceptions'] = false
    Rails.application.env_config['action_dispatch.show_detailed_exceptions'] = true
  end

  describe '500' do
    before do
      allow_any_instance_of(WelcomeController).to receive(:index).and_raise
    end

    it do
      visit '/'
      expect(page.status_code).to eq 500
      expect(page).to have_selector(:testid, 'errors/internal_server_error')
    end
  end

  describe 'unexpected error in show' do
    before do
      allow_any_instance_of(WelcomeController).to receive(:index).and_raise(StandardError)
      allow_any_instance_of(ErrorsController).to receive(:render_error_for).and_raise
    end

    it do
      visit '/'
      expect(page.status_code).to eq 500
      expect(page).to have_selector(:testid, 'errors/internal_server_error')
    end
  end

  describe '404' do
    before do
      allow_any_instance_of(WelcomeController).to receive(:index).and_raise(ActiveRecord::RecordNotFound)
    end

    it do
      visit '/'
      expect(page.status_code).to eq 404
      expect(page).to have_selector(:testid, 'errors/not_found')
    end
  end

  describe '422' do
    before do
      allow_any_instance_of(WelcomeController).to receive(:index).and_raise(ActiveRecord::RecordInvalid)
    end

    it do
      visit '/'
      expect(page.status_code).to eq 500
      expect(page).to have_selector(:testid, 'errors/internal_server_error')
    end
  end

  describe 'CSRF error' do
    before do
      allow_any_instance_of(WelcomeController).to receive(:index).and_raise(ActionController::InvalidAuthenticityToken)
    end

    it do
      visit '/'
      expect(page.status_code).to eq 422
      expect(page).to have_selector(:testid, 'errors/csrf')
    end
  end
end
