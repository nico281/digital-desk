Rails.application.routes.draw do
  # Públicas
  root "pages#home"

  get "/buscar", to: "search#index", as: :search
  resources :professionals, only: [ :index, :show ]
  resources :categories, only: [ :index, :show ]

  # Privadas (requieren auth)
  resource :dashboard, only: [ :show ]
  resources :bookings, only: [ :show, :create ] do
    member do
      post "confirm"
      post "cancel"
    end
  end

  # Panel profesional (requiere auth + role PRO)
  namespace :pro do
    resource :setup, only: [ :show, :update ]
    resources :services
    resources :availability_schedules
    resources :availability_blocks, only: [ :create, :destroy ]
    resources :bookings, only: [ :index ]
  end

  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
end
