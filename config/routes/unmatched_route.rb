# frozen_string_literal: true

Rails.application.routes.draw do
  get '*unmatched_route', to: 'application#route_not_found'
end
