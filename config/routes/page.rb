# frozen_string_literal: true

Rails.application.routes.draw do
  resource :page, only: [], path: '' do
    get :terms
    get :nda
    get '/policy' => redirect(Settings.routes.mirai_works_privacy_entry)
    get :support
    get :service
    get :staff
    get :sitemap
    get 'service/flow', action: :service_flow
    # get :faq
  end

  namespace :corp do
    root 'pages#index', trailing_slash: true
    get :performance, controller: :pages, as: :performance_page, trailing_slash: true
    get :statistics, controller: :pages, as: :statistics_page, trailing_slash: true
    get :terms, controller: :pages, as: :terms_page
  end
end
