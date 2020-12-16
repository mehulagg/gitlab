# frozen_string_literal: true

module API
  module Ci
    class PrometheusMetrics < ::API::Base
      params do
        requires :id, type: String, desc: 'The project ID'
      end
      resource :projects, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
        params do
          requires :metric_name, type: String, desc: 'The metric name that needs observing'
          requires :duration, type: Integer, desc: 'Duration value for metric'
        end
        post ':id/prometheus_metrics/:metric_name' do
          histogram = histograms.fetch(declared_params[:metric_name])
          histogram.observe({ project: user_project.full_path }, declared_params[:duration])

          status 200
          body ""
        end
      end
      helpers do
        def histograms
          @histograms ||= {
            'draw_links' => Gitlab::Metrics.histogram(:draw_links_total_duration_seconds, 'Total time spent drawing links, in seconds'),
            'other_metric_name' => :other_metric_definition_goes_here
          }
        end
      end
    end
  end
end
