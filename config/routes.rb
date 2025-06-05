Rails.application.routes.draw do
  mount_devise_token_auth_for "User", at: "auth", controllers: {
    sessions: "custom/sessions",
    registrations: "custom/registrations"
  }
  use_doorkeeper

  # /custom/...というURLで始まるAPIエンドポイントを定義
  namespace :custom do
    devise_scope :user do
      resource :sessions, only: [] do
        get :check_auth, on: :collection
        delete :logout, on: :collection
      end

      resource :users, only: [ :update ]
    end

    post "steam/register", to: "steam#register"
    get "steam/library", to: "steam#library"
    post "youtube/search", to: "youtube#search"
  end

  # devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
