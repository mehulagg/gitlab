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

      def self.thresholds
        @thresholds ||= THRESHOLDS.fetch(Rails.env.to_sym, DEFAULT_THRESHOLDS)
      end

      private

      def setup_subscribers
        super

        subscribe('sql.active_record') do |_, start, finish, _, data|
          detail_store << generate_detail(start, finish, data) if Gitlab::PerformanceBar.enabled_for_request?
        end
      end

      def generate_detail(start, finish, data)
        {
          start: start,
          finish: finish,
          duration: finish - start,
          sql: data[:sql].strip,
          backtrace: Gitlab::BacktraceCleaner.clean_backtrace(caller),
          cached: data[:cached] ? 'Cached by ActiveRecord' : '',
          transaction: data[:connection].transaction_open? ? 'In a transaction' : ''
        }
      end
    end
  end
end

Peek::Views::ActiveRecord.prepend_if_ee('EE::Peek::Views::ActiveRecord')
