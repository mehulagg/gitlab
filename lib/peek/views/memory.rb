# frozen_string_literal: true

module Peek
  module Views
    class Memory < DetailedView
      DEFAULT_THRESHOLDS = {
        calls: 30,
        duration: 1000,
        individual_call: 500
      }.freeze

      THRESHOLDS = {
        production: {
          calls: 30,
          duration: 1000,
          individual_call: 500
        }
      }.freeze

      def self.thresholds
        @thresholds ||= THRESHOLDS.fetch(Rails.env.to_sym, DEFAULT_THRESHOLDS)
      end

      private

      def duration
        0
      end

      def calls
        return 0 unless thread_memory

        thread_memory[:total_malloc_bytes]
      end

      def call_details
        {
        }
      end

      def thread_memory
        ::Gitlab::RequestContext.instance.final_thread_memory_allocations
      end

      def format_call_details(call)
        pretty_request = call[:request]&.reject { |k, v| v.blank? }.to_h.pretty_inspect

        super.merge(request: pretty_request || {})
      end
    end
  end
end
