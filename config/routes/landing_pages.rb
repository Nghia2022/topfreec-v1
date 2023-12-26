# frozen_string_literal: true

Rails.application.routes.draw do
  resources :landing_pages, path: 'lp', only: %i[show update], param: :name, trailing_slash: true do
    member do
      get :finish, trailing_slash: false
    end
  end
end
