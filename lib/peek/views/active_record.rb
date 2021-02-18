# frozen_string_literal: true

module Peek
  module Views
    class ActiveRecord < DetailedView
      DEFAULT_THRESHOLDS = {
        calls: 100,
        duration: 3000,
        individual_call: 1000
      }.freeze

      THRESHOLDS = {
        production: {
          calls: 100,
          duration: 15000,
          individual_call: 5000
        }
      }.freeze

      def results
        super.merge(calls: detailed_calls)
      end

      def self.thresholds
        @thresholds ||= THRESHOLDS.fetch(Rails.env.to_sym, DEFAULT_THRESHOLDS)
      end

      private

      def detailed_calls
        if Gitlab::Database::LoadBalancing.enable?
          "#{calls} (#{primary_calls} primary, #{replica_calls} replica, #{cached_calls} cached)"
        else
          "#{calls} (#{cached_calls} cached)"
        end
      end

      def cached_calls
        detail_store.count { |item| item[:cached] == 'cached' }
      end

      def primary_calls
        detail_store.count { |item| item[:host_type] == Gitlab::Database::LoadBalancing::HOST_PRIMARY }
      end

      def replica_calls
        detail_store.count { |item| item[:host_type] == Gitlab::Database::LoadBalancing::HOST_REPLICA }
      end

      def setup_subscribers
        super

        subscribe('sql.active_record') do |_, start, finish, _, data|
          if Gitlab::PerformanceBar.enabled_for_request?
            detail_store << {
              duration: finish - start,
              sql: data[:sql].strip,
              backtrace: Gitlab::BacktraceCleaner.clean_backtrace(caller),
              cached: data[:cached] ? 'cached' : '',
              host_type: Gitlab::Database::LoadBalancing.host_type(data[:connection])
            }
          end
        end
      end
    end
  end
end
