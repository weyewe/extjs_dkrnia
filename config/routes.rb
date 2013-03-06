ExtjsDikarunia::Application.routes.draw do
  devise_for :users
  root :to => 'home#index'

  namespace :api do
    devise_for :users
    match 'users/say_hi' => 'sessions#say_hi' , :as => :say_hi
  end

end
