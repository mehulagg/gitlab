# frozen_string_literal: true

namespace :security do
  root to: 'dashboard#show'
  get 'dashboard/settings', to: 'dashboard#settings', as: :settings_dashboard

  resources :projects, only: [:index, :create, :destroy]
  resources :vulnerabilities, only: [:index]
end
