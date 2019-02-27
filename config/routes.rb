# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#index'
  resources :countries, only: [:index, :show]
  resources :api, only: [:index, :show]
  post 'countries', to: 'countries#search'
end
