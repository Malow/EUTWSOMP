Rails.application.routes.draw do
  root 'application#index'
  
  get "/login" => "account#login"
  get "/register" => "account#register"
  
  resources :account, only: [:create]
  resources :role, only: [:create]
  resources :page_data, only: [:create]
  resources :mission, only: [:create]
  
  get "/password_reset" => "account#password_reset"
  
  get '*angular_route', to: 'application#index'
end
