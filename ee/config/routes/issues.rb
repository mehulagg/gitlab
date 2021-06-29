# frozen_string_literal: true

resources :issues, only: [], constraints: { id: /\d+/ } do
  member do
    get '/descriptions/:version_id/diff', action: :description_diff, as: :description_diff
    delete '/descriptions/:version_id', action: :delete_description_version, as: :delete_description_version
  end
  resources :issue_feature_flags, only: [:index, :show], as: 'feature_flags', path: 'feature_flags'
end
