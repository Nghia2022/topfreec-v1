# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin, path: 'fcweb-admin-01' do
    root 'welcome#index'

    resources :activations, only: %i[index edit update]
    namespace :salesforce do
      namespace :picklists do
        resource :reload
      end
    end
    namespace :projects do
      resources :experience_categories, only: %i[index]
    end
    resource :import, only: %i[new create]
  end
end
