# frozen_string_literal: true

module Gitlab
  module SidekiqDeathHandler
    class << self
      def handler(job, _exception)
        labels = Gitlab::SidekiqMiddleware::Metrics.create_labels(job['class'].constantize, job['queue'])

        counter.increment(labels)
      end

      def counter
        @counter ||= ::Gitlab::Metrics.counter(:sidekiq_jobs_dead_total, 'Sidekiq dead jobs')
      end
    end
  end
end
