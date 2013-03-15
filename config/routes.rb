ExtjsDikarunia::Application.routes.draw do
  devise_for :users
  root :to => 'home#index'

  namespace :api do
    devise_for :users
    match 'authenticate_auth_token' => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token
    match 'update_password' => "passwords#update" , :as => :update_password, :method => :put
    
    match 'search_customer' => 'customers#search', :as => :search_customer, :method => :get
    match 'search_employee' => 'employees#search', :as => :search_employee, :method => :get
    match 'search_vendor' => 'vendors#search', :as => :search_vendor, :method => :get
    match 'search_item' => 'items#search', :as => :search_items, :method => :get
    match 'search_purchase_order_entry' => 'purchase_order_entries#search', :as => :search_purchase_order_entries, :method => :get
    match 'search_sales_order_entry' => 'sales_order_entries#search', :as => :search_sales_order_entries, :method => :get
    
    match 'search_delivery' => 'deliveries#search', :as => :search_deliveries, :method => :get
    match 'search_delivery_entry' => 'delivery_entries#search', :as => :search_delivery_entries, :method => :get
    
    
    resources :employees
    resources :vendors
    resources :customers
    resources :app_users 
    resources :items 
    resources :stock_migrations 
    
    resources :purchase_orders
    match 'confirm_purchase_order' => 'purchase_orders#confirm' , :as => :confirm_purchase_order, :method => :post 
    resources :purchase_order_entries 
    
    resources :purchase_receivals
    match 'confirm_purchase_receival' => 'purchase_receivals#confirm', :as => :confirm_purchase_receival, :method => :post 
    resources :purchase_receival_entries
    
    
    resources :sales_orders 
    match 'confirm_sales_order' => 'sales_orders#confirm', :as => :confirm_sales_order, :method => :post
    resources :sales_order_entries
    
    resources :deliveries 
    match 'confirm_delivery' => 'deliveries#confirm', :as => :confirm_delivery, :method => :post
    resources :delivery_entries 
    match 'update_post_delivery' => 'delivery_entries#update_post_delivery', :as => :update_post_delivery, :method => :post
    
    resources :sales_returns
    match 'confirm_sales_return' => 'sales_returns#confirm', :as => :confirm_sales_return, :method => :post
    resources :sales_return_entries 
    
    resources :delivery_losts
    match 'confirm_delivery_lost' => 'delivery_losts#confirm', :as => :confirm_delivery_lost, :method => :post
    resources :delivery_lost_entries 
  end

end
