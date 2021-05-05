# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    class KubernetesAgentCounter < BaseCounter
      PREFIX = 'kubernetes_agent'
      KNOWN_EVENTS = %w[gitops_sync proxy_request].freeze

      class << self
        def increment_event_counts(events)
          validate!(events)

          events.each do |event, incr|
            # rather then hitting redis for this no-op, we return early
            next if incr.zero?

            increment_by(redis_key(event), incr)
          end
        end

        private

        def validate!(events)
          events.each do |event, incr|
            raise ArgumentError, "unknown event #{event}" unless event.in?(KNOWN_EVENTS)
            raise ArgumentError, "#{event} count must be greater than or equal to zero" if incr.negative?
          end
        end
      end
    end
  end
end
