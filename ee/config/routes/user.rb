# frozen_string_literal: true

get  'unsubscribes/:email', to: 'unsubscribes#show', as: :unsubscribe
post 'unsubscribes/:email', to: 'unsubscribes#create'

devise_scope :user do
  get '/users/auth/kerberos_spnego/negotiate' => 'omniauth_kerberos_spnego#negotiate'
end

scope(constraints: { username: Gitlab::PathRegex.root_namespace_route_regex }) do
  scope(path: 'users/:username',
        as: :user,
        controller: :users) do
    get :available_project_templates, format: :js
    get :available_group_templates, format: :js
    get :pipelines_quota
  end
end
