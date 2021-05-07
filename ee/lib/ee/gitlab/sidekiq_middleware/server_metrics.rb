# frozen_string_literal: true
module EE
  module Gitlab
    module SidekiqMiddleware
      module ServerMetrics
        extend ::Gitlab::Utils::Override

        protected

        override :init_metrics
        def init_metrics
          super.merge(init_load_balancing_metrics)
        end

        override :instrument
        def instrument(job, labels)
          super
        ensure
          record_load_balancing(job, labels)
        end

        private

        def init_load_balancing_metrics
          return {} unless ::Gitlab::Database::LoadBalancing.enable?

          {
            sidekiq_load_balancing_count: ::Gitlab::Metrics.counter(:sidekiq_load_balancing_count, 'Sidekiq jobs with load balancing')
          }
        end

        def record_load_balancing(job, labels)
          return unless ::Gitlab::Database::LoadBalancing.enable?
          return unless job[:database_chosen]

          load_balancing_labels = {
            database_chosen: job[:database_chosen],
            data_consistency: job[:data_consistency]
          }

          metrics[:sidekiq_load_balancing_count].increment(labels.merge(load_balancing_labels), 1)
        end
      end
    end
  end
end
