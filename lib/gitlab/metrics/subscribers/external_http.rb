# frozen_string_literal: true

module Gitlab
  module Metrics
    module Subscribers
      # Class for tracking the total time spent in external HTTP
      # TODO: Link to labkit notifications here
      class ExternalHttp < ActiveSupport::Subscriber
        attach_to :external_http

        DETAIL_STORE = :external_http_detail_store
        COUNTER = :external_http_count
        DURATION = :external_http_duration

        KNOWN_PAYLOAD_KEYS = [COUNTER, DURATION].freeze

        def self.detail_store
          return [] if !Gitlab::SafeRequestStore.active? || !Gitlab::PerformanceBar.enabled_for_request?

          ::Gitlab::SafeRequestStore[DETAIL_STORE] ||= []
        end

        def self.duration
          return 0.0 unless Gitlab::SafeRequestStore.active?

          Gitlab::SafeRequestStore[DURATION].to_f
        end

        def self.request_count
          return 0 unless Gitlab::SafeRequestStore.active?

          Gitlab::SafeRequestStore[COUNTER].to_i
        end

        def self.payload
          return {} unless Gitlab::SafeRequestStore.active?

          {
            COUNTER => request_count,
            DURATION => duration
          }
        end

        def request(event)
          payload = event.payload
          add_to_detail_store(payload)
          add_to_request_store(payload)
          expose_metrics(payload)
        end

        private

        def current_transaction
          ::Gitlab::Metrics::Transaction.current
        end

        def add_to_detail_store(payload)
          return unless Gitlab::PerformanceBar.enabled_for_request?

          self.class.detail_store << {
            duration: payload[:duration],
            scheme: payload[:scheme],
            method: payload[:method],
            host: payload[:host],
            port: payload[:port],
            path: payload[:path],
            query: payload[:query],
            code: payload[:code],
            exception_object: payload[:exception_object],
            backtrace: Gitlab::BacktraceCleaner.clean_backtrace(caller)
          }
        end

        def add_to_request_store(payload)
          return unless Gitlab::SafeRequestStore.active?

          Gitlab::SafeRequestStore[COUNTER] = Gitlab::SafeRequestStore[COUNTER].to_i + 1
          Gitlab::SafeRequestStore[DURATION] = Gitlab::SafeRequestStore[DURATION].to_f + payload[:duration].to_f
        end

        def expose_metrics(payload)
          return unless current_transaction

          labels = { method: payload[:method], code: payload[:code] }

          current_transaction.increment(:gitlab_external_http_total, 1, labels) do
            docstring 'External HTTP calls'
            label_keys labels.keys
          end

          current_transaction.observe(:gitlab_external_http_duration_seconds, payload[:duration]) do
            docstring 'External HTTP time'
            buckets [0.001, 0.01, 0.1, 1.0, 2.0, 5.0]
          end

          if payload[:exception_object].present?
            current_transaction.increment(:gitlab_external_http_exception_total, 1) do
              docstring 'External HTTP exceptions'
            end
          end
        end
      end
    end
  end
end
