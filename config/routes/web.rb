# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :fc_users, path: :user, as: :fc_user do
    resource :activation, only: %i[show]
  end

  resources :projects, only: %i[index], path: 'project' do
    collection do
      get :featured
    end
  end
  resources :projects, only: %i[show], path: 'job' do
    scope module: :projects do
      resource :entry, only: %i[new create], format: 'html'
      collection do
        resource :entry, only: %i[], format: 'html' do
          get :thanks
        end
      end
    end
  end
  resources :projects, only: %i[] do
    collection do
      get ':slug', to: 'projects#index', as: :slug
    end
  end
  resources :cases, only: %i[new create] do
    collection do
      get :thanks
    end
  end

  scope module: :content do
    concern :detail_with_trailing_slash do
      member do
        get :show, trailing_slash: true
      end
    end

    resources :columns, only: %i[], path: 'column', concerns: :detail_with_trailing_slash, as: :content_columns do
      collection do
        get :index, path: '(/categ/:tag)'
      end
    end
    resources :workstyles, only: %i[index], concerns: :detail_with_trailing_slash, path: 'workstyle', as: :content_workstyles
    resources :blogs, only: %i[index], path: 'ceo_blog', concerns: :detail_with_trailing_slash, as: :content_blogs
    resources :interviews, only: %i[index show], path: 'corp/interview', as: :corp_interviews
    resources :topics, only: %i[index], path: 'topics', as: :content_topics
    resources :business_columns, only: %i[index show], path: 'corp/business-column', as: :corp_business_columns
  end

  get '/auth/:provider/callback', to: 'oauth_sessions#create'
  get '/auth/failure', to: 'oauth_sessions#failure'
  resource :oauth_session, only: %i[destroy]

  root 'welcome#index'
end
