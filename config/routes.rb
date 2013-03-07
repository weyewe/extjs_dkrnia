ExtjsDikarunia::Application.routes.draw do
  devise_for :users
  root :to => 'home#index'

  namespace :api do
    devise_for :users
    match 'api/authenticate_auth_token' => 'api/sessions#authenticate_auth_token', :as => :authenticate_auth_token
    resources :employees
    
    match 'update_password' => "passwords#update" , :as => :update_password, :method => :put
  end

end
