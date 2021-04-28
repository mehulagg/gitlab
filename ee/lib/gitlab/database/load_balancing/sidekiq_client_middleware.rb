# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqClientMiddleware
        def call(worker_class, job, _queue, _redis_pool)
          worker_class = worker_class.to_s.safe_constantize

          mark_data_consistency_location(worker_class, job)

          yield
        end

        private

        def mark_data_consistency_location(worker_class, job)
          # Mailers can't be constantized
          return unless worker_class
          return unless worker_class.include?(::ApplicationWorker)
          return unless worker_class.get_data_consistency_feature_flag_enabled?

          job['worker_data_consistency'] = worker_class.get_data_consistency

          return if worker_class.get_data_consistency == :always

          if Session.current.performed_write?
            job['database_write_location'] = load_balancer.primary_write_location
          else
            job['database_replica_location'] = load_balancer.host.database_replica_location
          end
        end

        def load_balancer
          LoadBalancing.proxy.load_balancer
        end
      end
    end
  end
end
