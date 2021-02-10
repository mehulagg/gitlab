# frozen_string_literal: true

get 'operations' => 'operations#index'
get 'operations/environments' => 'operations#environments'
get 'operations/list' => 'operations#list'
get 'operations/environments_list' => 'operations#environments_list'
post 'operations' => 'operations#create', as: :add_operations_project
delete 'operations' => 'operations#destroy', as: :remove_operations_project
