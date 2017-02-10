Rails.application.routes.draw do
  resources :results
  resources :patients
  resources :devices
  resources :consumables
  resources :businesses
  resources :statuses
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root :to => "welcome#index"
  get 'welcome/index'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
