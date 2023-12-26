# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :mypage, format: 'html' do
    concern :memberable do
      resource :email, only: %i[edit update]
      resources :settings, only: %i[index]
      resources :bookmarks, only: %i[index]
      resources :histories, only: %i[index]

      root 'dashboard#index'
    end

    concern :directionable do
      resources :directions, only: %i[index] do
        scope module: :directions do
          resource :approve, only: %i[show create]
          resource :reject, only: %i[show create]
        end
      end
    end

    namespace :fc do
      resource :registration, path: :register, only: %i[show create]
      concerns :memberable
      resource :password, only: %i[new create edit update]
      resource :profile, only: %i[show edit update]
      namespace :phone do
        resource :confirmation, only: %i[show create] do
          put :resend_code, action: 'update'
        end
      end
      namespace :profiles, as: :profile, path: :profile do
        resource :general, only: %i[edit update]
        resources :educations, only: %i[new create edit update destroy]
        resources :work_histories, only: %i[new create edit update destroy]
        resource :qualification, only: %i[edit update]
        resource :desired_condition, only: %i[edit update]
        resource :profile_image, only: %i[edit update]
      end
      namespace :settings do
        resource :ml_reject, only: %i[edit update destroy]
        resource :resumes, only: %i[new create]
        resource :desired_condition, only: %i[edit update]
        resource :experienced_work_category, only: %i[edit update]
        resource :desired_work_category, only: %i[edit update]
        resource :project_request, only: %i[edit update]
      end
      resources :entries, only: %i[index destroy] do
        get 'status_info', action: 'status_info', on: :collection
        member do
          get :decline
        end
      end
      concerns :directionable
      resources :experiences, only: %i[index new create edit update destroy] do
        member do
          post 'publish', action: 'publish'
          post 'close', action: 'close'
        end
      end
      resource :project_request, only: %i[edit update]
    end

    namespace :client, path: :cl do
      concerns :memberable
      concerns :directionable
      resource :password, only: %i[edit update]
    end

    resources :receipts, only: %i[update]

    root 'root#index'
  end
end
