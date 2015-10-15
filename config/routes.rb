Rails.application.routes.draw do
  root 'application#index'
  
  get "/login" => "authentication#is_logged_in_then_go_to_dashboard"
  get "/register" => "authentication#is_logged_in_then_go_to_dashboard"
  get "/account_settings" => "authentication#is_not_logged_in_then_go_to_root"
  
  resources :authentication, only: [:create]
  
  get '*angular_route', to: 'application#index'
end
