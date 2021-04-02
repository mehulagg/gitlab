# frozen_string_literal: true
module EE
  module Gitlab
    module SidekiqMiddleware
      module ServerMetrics
        extend ::Gitlab::Utils::Override

        override :initialize
        def initialize
          super
          init_load_balancing_metrics
        end

        override :call
        def call(worker, job, queue)
          super
        ensure
          record_load_balancing(job, labels)
        end

        private

        def init_load_balancing_metrics
          return unless ::Gitlab::Database::LoadBalancing.enable?

          metrics.merge!(
            {
              sidekiq_load_balancing_count: ::Gitlab::Metrics.counter(:sidekiq_load_balancing_count, 'Sidekiq jobs with load balancing')
            })
        end

        def record_load_balancing(job, labels)
          return unless ::Gitlab::Database::LoadBalancing.enable?
          return unless job[:database_chosen]

          labels[:database_chosen] = job[:database_chosen]
          metrics[:sidekiq_load_balancing_count].increment(labels, 1)
        end
      end
    end
  end
end
