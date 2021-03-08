# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqClientMiddleware
        def call(worker_class, job, _queue, _redis_pool)
          mark_data_consistency_location(worker_class, job)

          yield
        end

        private

        def mark_data_consistency_location(worker_class, job)
          worker_class = worker_class.to_s.safe_constantize
          return if worker_class.get_data_consistency == :always

          return unless worker_class.get_data_consistency_feature_flag_enabled?

          if Session.current.performed_write?
            job['database_write_location'] = load_balancer.primary_write_location
          else
            job['database_replica_location'] = true
          end
        end

        def load_balancer
          LoadBalancing.proxy.load_balancer
        end
      end
    end
  end
end
