Rails.application.routes.draw do
  root 'application#index'
  
  get "/login" => "account#login"
  get "/register" => "account#register"
  
  resources :account, only: [:create]
  resources :page_data, only: [:create]
  
  get '*angular_route', to: 'application#index'
end
