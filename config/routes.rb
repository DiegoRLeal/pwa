Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  root to: "students#new"
  resources :students
  get 'cancelado', to: 'students#cancelado'
  get '/offline', to: 'students#offline', as: :offline
end
