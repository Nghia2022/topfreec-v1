# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :fc_users, only: [], param: :contact_sfid do
        member do
          put 'activate'
        end
      end
      resources :cloudinary_signatures, only: %i[create]
    end
  end
end
