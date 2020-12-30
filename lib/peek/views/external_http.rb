# frozen_string_literal: true

module Peek
  module Views
    class ExternalHttp < DetailedView
      DEFAULT_THRESHOLDS = {
        calls: 10,
        duration: 1000,
        individual_call: 100
      }.freeze

      THRESHOLDS = {
        production: {
          calls: 100,
          duration: 15000,
          individual_call: 5000
        }
      }.freeze

      def key
        'external-http'
      end

      def results
        super.merge(calls: calls)
      end

      def self.thresholds
        @thresholds ||= THRESHOLDS.fetch(Rails.env.to_sym, DEFAULT_THRESHOLDS)
      end

      def format_call_details(call)
        uri = URI("")
        uri.scheme = call[:scheme]
        uri.host = call[:host]
        uri.port = call[:port]
        uri.path = call[:path]
        uri.query = call[:query]

        proxy =
          if call[:proxy_host].present?
            "Proxied via #{call[:proxy_host]}:#{call[:proxy_port]}"
          else
            nil
          end

        code =
          if call[:code].present?
            "Response status: #{call[:code]}"
          else
            nil
          end

        error =
          if call[:exception_object].present?
            "Exception: #{call[:exception_object]}"
          else
            nil
          end

        super.merge(
          label: "#{call[:method]} #{uri}",
          code: code,
          proxy: proxy,
          error: error
        )
      end

      private

      def duration
        ::Gitlab::Metrics::Subscribers::ExternalHttp.duration * 1000
      end

      def calls
        ::Gitlab::Metrics::Subscribers::ExternalHttp.request_count
      end

      def call_details
        ::Gitlab::Metrics::Subscribers::ExternalHttp.detail_store
      end
    end
  end
end
