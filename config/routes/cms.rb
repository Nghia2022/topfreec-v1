# frozen_string_literal: true

namespace :wp_users, as: :wp_user do
  resource :session, only: [], path: '' do
    get :new, path: :sign_in, as: :new
    post :create, path: :sign_in
    match :destroy, path: :sign_out, as: :destroy, via: :delete
  end
end

namespace :cms do
  root to: 'dashboard#index'
end
