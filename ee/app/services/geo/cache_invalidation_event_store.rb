# frozen_string_literal: true

module Geo
  class CacheInvalidationEventStore < EventStore
    self.event_type = :cache_invalidation_event

    attr_reader :key

    def initialize(key)
      @key = key
    end

    private

    def build_event
      Geo::CacheInvalidationEvent.new(key: key)
    end

    # This is called by LogHelpers to build json log with context info
    #
    # @see ::Gitlab::Geo::LogHelpers
    def extra_log_data
      {
        cache_key: key.to_s,
        job_id: get_sidekiq_job_id
      }.compact
    end
  end
end
