Rails.application.routes.draw do
  devise_for :users
  root to: 'apartments#index'
  resources :apartments, only: [:index]
  get '/offline', to: 'pages#offline', as: :offline
end
