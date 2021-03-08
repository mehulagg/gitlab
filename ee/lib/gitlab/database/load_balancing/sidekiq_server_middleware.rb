# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqServerMiddleware

        SecondariesStaleError = Class.new(StandardError)

        def call(worker, job, _queue)
          clear

          if worker.class.data_consistency == :always
            Session.current.use_primary!
          else
            retry_count = job[:retry_count].present? ? job[:retry_count].to_i + 1 : 0
            location = job[:primary_write_location]
            stick_or_delay_if_necessary(worker.class.data_consistency, location, retry_count)
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

        def stick_or_delay_if_necessary(data_consistency, location, retry_count)
          unless all_caught_up?(location)
            if data_consistency == :sticky || retry_count > 1
              Session.current.use_primary!
              log_warning(data_consistency, retry_count, "Using primary instead.")
            else
              log_warning(data_consistency, retry_count, "Retrying the worker.")
              raise SecondariesStaleError.new("Not all Hosts have caught up to the given transaction write location.")
            end
          end
        end

        def log_warning(data_consistency, retry_count, message)
          full_message = "Not all Hosts have caught up to the given transaction write location. #{message}"

          LoadBalancing::Logger.warn(
            event: :hosts_not_caught_up_for_sidekiq,
            message: full_message,
            worker_data_consistency: data_consistency,
            retry_count: retry_count
          )
        end

        def load_balancer
          LoadBalancing.proxy.load_balancer
        end

        def all_caught_up?(location)
          load_balancer.all_caught_up?(location)
        end
      end
    end
  end
end
