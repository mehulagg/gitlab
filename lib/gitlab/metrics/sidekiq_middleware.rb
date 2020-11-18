# frozen_string_literal: true

module Gitlab
  module Metrics
    # Sidekiq middleware for tracking jobs.
    #
    # This middleware is intended to be used as a server-side middleware.
    class SidekiqMiddleware
      def call(worker, payload, queue)
        yield
      ensure
        payload.merge!(::Gitlab::Metrics::Subscribers::ActiveRecord.db_counter_payload)
      end
    end
  end
end
