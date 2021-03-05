# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqServerMiddleware

        SecondariesStaleError = Class.new(StandardError)

        def call(worker, job, _queue)
          clear

          if worker.class.always?
            Session.current.use_primary!
          else
            retry_count = job[:retry_count].present? ? job[:retry_count].to_i + 1 : 0
            location = job[:primary_write_location]
            stick_or_delay_if_necessary(worker.class.sticky?, location, retry_count)
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

        def stick_or_delay_if_necessary(sticky, location, retry_count)
          unless all_caught_up?(location)
            if sticky || retry_count > 1
              Session.current.use_primary!
            else
              raise SecondariesStaleError.new("Replicas haven't caught up to the given transaction")
            end
          end
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
