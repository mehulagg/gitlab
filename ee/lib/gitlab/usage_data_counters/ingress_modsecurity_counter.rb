# frozen_string_literal: true

module Gitlab::UsageDataCounters
  class IngressModsecurityCounter < BaseCounter
    KNOWN_EVENTS = %w[statistics_unavailable packets_processed packets_anomalous].freeze
    PREFIX = 'ingress_modsecurity'

    class << self
      def add(statistics_unavailable, packets_processed, packets_anomalous)
        return unless Gitlab::CurrentSettings.usage_ping_enabled?

        Gitlab::Redis::SharedState.with do |redis|
          redis.multi do
            redis.set(redis_key(:statistics_unavailable), statistics_unavailable)
            redis.incrby(redis_key(:packets_processed), packets_processed)
            redis.incrby(redis_key(:packets_anomalous), packets_anomalous)
          end
        end
      end
    end
  end
end
