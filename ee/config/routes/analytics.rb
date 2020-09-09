# frozen_string_literal: true

namespace :analytics do
  root to: redirect('admin/dev_ops_score')

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

  scope :type_of_work do
    resource :tasks_by_type, controller: :tasks_by_type, only: :show do
      get :top_labels
    end
  end
end
