# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  use_doorkeeper
  use_doorkeeper_openid_connect do
    controllers discovery: 'oauth/openid_connect/discovery'
  end

  apipie
  constraints AuthenticateAdminConstraint.new do
    mount RailsAdmin::Engine, at: '/dev-tools/admin', as: 'rails_admin'
    mount LetterOpenerWeb::Engine, at: '/dev-tools/letter_opener'
    mount Flipper::UI.app(Flipper) => '/dev-tools/flipper'
    mount Sidekiq::Web, at: '/sidekiq'
    mount Blazer::Engine, at: '/admin/blazer'
  end

  get '/dev-tools/admin', to: redirect('/admin')
  get '/dev-tools/letter_opener', to: redirect('/admin')
  get '/dev-tools/flipper', to: redirect('/admin')
  get '/sidekiq', to: redirect('/admin')
  get '/admin/blazer', to: redirect('/admin')
end
