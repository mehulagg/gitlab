# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqServerMiddleware
        JobReplicaNotUpToDate = Class.new(StandardError)

        def call(worker, job, _queue)
          worker_class = worker.class
          db_strategy = select_database_strategy(worker_class, job)

          job[:database_chosen] = db_strategy.to_s
          job[:data_consistency] = safe_get_data_consistency(worker_class).to_s

          case db_strategy
          when :primary then
            Session.current.use_primary!
          when :retry
            raise JobReplicaNotUpToDate, "Sidekiq job #{worker_class} JID-#{job['jid']} couldn't use the replica."\
               "  Replica was not up to date."
          else
            # this means we selected an up-to-date replica, but there is nothing to do in this case.
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

        def safe_get_data_consistency(worker_class)
          worker_class.try(:get_data_consistency) || :always
        end

        def select_database_strategy(worker_class, job)
          return :primary unless load_balancing_available?(worker_class)

          location = job['database_write_location'] || job['database_replica_location']
          return :primary unless location

          if replica_caught_up?(location)
            :replica
          elsif worker_class.get_data_consistency == :delayed && not_yet_retried?(job)
            :retry
          else
            :primary
          end
        end

        def load_balancing_available?(worker_class)
          worker_class.include?(::ApplicationWorker) &&
            worker_class.utilizes_load_balancing_capabilities? &&
            worker_class.get_data_consistency_feature_flag_enabled?
        end

        def not_yet_retried?(job)
          # if `retry_count` is `nil` it indicates that this job was never retried
          # the `0` indicates that this is a first retry
          job['retry_count'].nil?
        end

        def load_balancer
          LoadBalancing.proxy.load_balancer
        end

        def replica_caught_up?(location)
          load_balancer.host.caught_up?(location)
        end
      end
    end
  end
end
