# frozen_string_literal: true

namespace :analytics do
  root to: 'analytics#index'

  constraints(::Constraints::FeatureConstrainer.new(Gitlab::Analytics::REPORT_PAGES_FEATURE_FLAG)) do
    get :report_pages, to: 'reports/pages#show'
  end

  constraints(-> (req) { Gitlab::Analytics.cycle_analytics_enabled? }) do
    resource :cycle_analytics, only: :show, path: 'value_stream_analytics'
    scope module: :cycle_analytics, as: 'cycle_analytics', path: 'value_stream_analytics' do
      resources :stages, only: [:index, :create, :update, :destroy] do
        member do
          get :duration_chart
          get :median
          get :records
        end
      end
      resource :summary, controller: :summary, only: :show
      get '/time_summary' => 'summary#time_summary'
    end
    get '/cycle_analytics', to: redirect('-/analytics/value_stream_analytics')
  end

  scope :type_of_work do
    resource :tasks_by_type, controller: :tasks_by_type, only: :show do
      get :top_labels
    end
  end
end
