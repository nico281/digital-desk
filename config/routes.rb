Rails.application.routes.draw do
  # Públicas
  root "pages#home"

  get "/buscar", to: "search#index", as: :search
  resources :professionals, only: [ :show ] do
    get :slots, on: :member
  end

  # Privadas (requieren auth)
  resource :dashboard, only: [ :show ]
  resource :account, only: [ :show, :update ]
  resources :bookings, only: [ :show, :create ] do
    member do
      post "confirm"
      post "cancel"
      post "livekit_token"
      get "room"
    end
    resource :review, only: [ :create ]
    collection do
      get "complete_pending"
    end
  end

  # Panel profesional (requiere auth + role PRO)
  namespace :pro do
    resource :setup, only: [ :show, :update ]
    resources :services
    resources :availability_schedules do
      collection { post :batch; delete :reset }
    end
    patch "block_settings", to: "availability_schedules#update_settings"
    resources :availability_blocks, only: [ :create, :destroy ]
    resources :bookings, only: [ :index ] do
      member do
        post :confirm
        post :reject
      end
    end
    resources :reviews, only: [ :index ] do
      member { patch :reply }
    end
  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  get "up" => "rails/health#show", as: :rails_health_check
end
