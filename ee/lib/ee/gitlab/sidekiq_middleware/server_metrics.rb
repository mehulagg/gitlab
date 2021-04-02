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
              sidekiq_load_balancing_caught_up_fallbacks_count: ::Gitlab::Metrics.counter(:sidekiq_load_balancing_caught_up_fallbacks_count, 'Sidekiq jobs fallen back to the primary'),
              sidekiq_load_balancing_use_primary_count:         ::Gitlab::Metrics.counter(:sidekiq_load_balancing_use_primary_count, 'Sidekiq jobs using primary'),
              sidekiq_load_balancing_use_replica_count:         ::Gitlab::Metrics.counter(:sidekiq_load_balancing_use_replica_count, 'Sidekiq jobs using replica'),
              sidekiq_load_balancing_wait_for_replica_count:    ::Gitlab::Metrics.counter(:sidekiq_load_balancing_wait_for_replica_count, 'Sidekiq jobs retried, replica was not up to date')
            })
        end

        def record_load_balancing(job, labels)
          return unless ::Gitlab::Database::LoadBalancing.enable?

          if job[:wait_for_replica]
            metrics[:sidekiq_load_balancing_wait_for_replica_count].increment(labels, 1)
          elsif job[:use_primary]
            metrics[:sidekiq_load_balancing_use_primary_count].increment(labels, 1)
            metrics[:sidekiq_load_balancing_caught_up_fallbacks_count].increment(labels, 1) if job[:fallback_to_primary]
          else
            metrics[:sidekiq_load_balancing_use_replica_count].increment(labels, 1)
          end
        end
      end
    end
  end
end
