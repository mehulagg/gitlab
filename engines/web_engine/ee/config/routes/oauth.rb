# frozen_string_literal: true

namespace :oauth do
  scope path: 'geo', controller: :geo_auth, as: :geo do
    get 'auth'
    get 'callback'
    get 'logout'
  end
end
