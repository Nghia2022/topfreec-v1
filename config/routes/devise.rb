# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :fc_users,
             path:        '',
             path_names:  {
               sign_up:      '',
               sign_in:      'user/sign_in',
               registration: 'register'
             },
             controllers: {
               passwords:        'fc_users/passwords',
               sessions:         'fc_users/sessions',
               password_expired: 'password_expired'
               # two_factor_authentication: 'fc_users/two_factor_authentication'
             },
             skip:        %i[registrations]

  devise_for :client_users,
             path:        'client',
             controllers: {
               sessions:         'client_users/sessions',
               passwords:        'client_users/passwords',
               password_expired: 'password_expired'
             }

  devise_scope :fc_user do
    unauthenticated do
      get 'password/guide' => 'fc_users/passwords#guide', as: :guide_fc_user_password
      resource :registration, controller: 'fc_users/registrations', path: 'register', only: %i[], as: :fc_user_registration do
        get :new, trailing_slash: true, as: :new
        post :create, trailing_slash: true
        get :thanks
      end
    end
    authenticated do
      get 'register' => redirect('mypage/fc', status: 302)
    end
  end

  devise_scope :client_user do
    unauthenticated do
      get 'client/sign_up/thanks' => 'client_users/registrations#thanks', as: :thanks_client_user_registration
      get 'client/password/guide' => 'client_users/passwords#guide', as: :guide_client_user_password
    end
  end
end
