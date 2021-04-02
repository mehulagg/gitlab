# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqServerMiddleware
        include ::Gitlab::SidekiqMiddleware::MetricsHelper

        JobReplicaNotUpToDate = Class.new(StandardError)

        def call(worker, job, _queue)
          if (job[:use_primary] = requires_primary?(worker.class, job))
            Session.current.use_primary!
          end

          yield
        ensure
          clear
        end

        private

        def clear
          load_balancer.release_host
          Session.clear_session
        end

        def requires_primary?(worker_class, job)
          return true unless worker_class.include?(::ApplicationWorker)

          job[:worker_data_consistency] = worker_class.get_data_consistency

          return true if worker_class.get_data_consistency == :always
          return true unless worker_class.get_data_consistency_feature_flag_enabled?

          if job['database_replica_location'] || replica_caught_up?(job['database_write_location'])
            false
          elsif worker_class.get_data_consistency == :delayed && job['retry_count'].to_i == 0
            job[:wait_for_replica] = true
            raise JobReplicaNotUpToDate, "Sidekiq job #{worker_class} JID-#{job['jid']} couldn't use the replica."\
               "  Replica was not up to date."
          else
            job[:fallback_to_primary] = true
            true
          end
        end

        def load_balancer
          LoadBalancing.proxy.load_balancer
        end

        def replica_caught_up?(location)
          return true unless location

          load_balancer.host.caught_up?(location)
        end
      end
    end
  end
end
