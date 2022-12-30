Rails.application.routes.draw do
  root to: 'apartments#index'
  resources :apartments, only: [:index]
  get '/offline', to: 'pages#offline', as: :offline
end
