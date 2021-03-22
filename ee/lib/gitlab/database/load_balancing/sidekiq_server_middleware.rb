# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqServerMiddleware
        def call(worker, job, _queue)
          if requires_primary?(worker.class, job)
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
          job[:worker_data_consistency] = worker_class.get_data_consistency

          return true if worker_class.get_data_consistency == :always
          return true unless worker_class.get_data_consistency_feature_flag_enabled?

          location = job['database_replica_location'] || job['database_write_location']
          if replica_caught_up?(location)
            false
          elsif worker_class.get_data_consistency == :delayed
            attempt_retry(worker_class, job)
          else
            true
          end
        end

        def attempt_retry(worker_class, job)
          max_retry_attempts = worker_class.get_max_replica_retry_count

          if job["delayed_retry"].nil?
            job["delayed_retry"] = max_retry_attempts
          end

          count = if job["delayed_retry_count"]
                    job["delayed_retry_count"] += 1
                  else
                    job["failed_at"] = Time.now.to_f
                    job["delayed_retry_count"] = 0
                  end

          if count < max_retry_attempts
            retry_at = Time.now.to_f + delay(count)
            payload = Sidekiq.dump_json(job)
            Sidekiq.redis do |conn|
              conn.zadd("retry", retry_at.to_s, payload)
            end
            raise ::Sidekiq::Shutdown
          else
            true
          end
        end

        def delay(count)
          (count**4) + 15 + (rand(30) * (count + 1))
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
