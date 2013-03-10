ExtjsDikarunia::Application.routes.draw do
  devise_for :users
  root :to => 'home#index'

  namespace :api do
    devise_for :users
    match 'authenticate_auth_token' => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token
    match 'update_password' => "passwords#update" , :as => :update_password, :method => :put
    
    match 'search_vendor' => 'vendors#search', :as => :search_vendor, :method => :get
    match 'search_item' => 'items#search', :as => :search_items, :method => :get
    
    resources :employees
    resources :vendors
    resources :customers
    resources :app_users 
    resources :items 
    resources :stock_migrations 
    
    resources :purchase_orders
    match 'confirm_purchase_order' => 'purchase_orders#confirm' , :as => :confirm_purchase_order, :method => :post 
    resources :purchase_order_entries 
  end

end
