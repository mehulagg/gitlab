# frozen_string_literal: true

module Geo
  # Called by Geo::EventWorker to consume the event
  class EventService
    include ::Gitlab::Geo::LogHelpers
    include ::Gitlab::Utils::StrongMemoize

    attr_reader :replicable_name, :event_name, :payload

    def initialize(replicable_name, event_name, payload)
      @replicable_name = replicable_name
      @event_name = event_name.to_sym
      @payload = payload.symbolize_keys
    end

    def execute
      replicator.consume(event_name, **payload)
    end

    private

    def replicator
      strong_memoize(:replicator) do
        model_record_id = payload[:model_record_id]

        ::Gitlab::Geo::Replicator.for_replicable_params(replicable_name: replicable_name, replicable_id: model_record_id)
      end
    end

    def extra_log_data
      {
        replicable_name: replicable_name,
        event_name: event_name,
        payload: payload
      }
    end
  end
end
