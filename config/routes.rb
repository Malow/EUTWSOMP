Rails.application.routes.draw do
  root 'application#index'
  
  get "/login" => "authentication#is_logged_in"
  get "/register" => "authentication#is_logged_in"
  get "/account_settings" => "authentication#is_logged_in"
  
  resources :authentication, only: [:create]
  
  get '*angular_route', to: 'application#index'
end
