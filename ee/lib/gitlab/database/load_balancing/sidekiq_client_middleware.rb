# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class SidekiqClientMiddleware
        def call(worker_class, job, _queue, _redis_pool)
          mark_primary_write_location(worker_class, job)

          yield
        end

        def mark_primary_write_location(worker_class, job)
          return unless LoadBalancing.enable? || !worker_class.always? || Session.current.performed_write?

          Sticking.with_primary_write_location do |location|
            job[:primary_write_location] = location
          end
        end
      end
    end
  end
end
