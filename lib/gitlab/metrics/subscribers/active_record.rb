# frozen_string_literal: true

module Gitlab
  module Metrics
    module Subscribers
      # Class for tracking the total query duration of a transaction.
      class ActiveRecord < ActiveSupport::Subscriber
        attach_to :active_record

        IGNORABLE_SQL = %w{BEGIN COMMIT}.freeze
        DB_COUNTERS = %i{db_count db_write_count db_cached_count}.freeze
        DB_LOAD_BALANCING_COUNTERS = %i{db_replica_count db_replica_cached_count db_primary_count db_primary_cached_count}.freeze
        SQL_COMMANDS_WITH_COMMENTS_REGEX = /\A(\/\*.*\*\/\s)?((?!(.*[^\w'"](DELETE|UPDATE|INSERT INTO)[^\w'"])))(WITH.*)?(SELECT)((?!(FOR UPDATE|FOR SHARE)).)*$/i.freeze

        def sql(event)
          # Mark this thread as requiring a database connection. This is used
          # by the Gitlab::Metrics::Samplers::ThreadsSampler to count threads
          # using a connection.
          Thread.current[:uses_db_connection] = true

          payload = event.payload
          return if payload[:name] == 'SCHEMA' || IGNORABLE_SQL.include?(payload[:sql])

          increment_db_counters(event)
          observe_db_duration(event)

          if Gitlab::Database::LoadBalancing.enable?
            host_type = Gitlab::Database::LoadBalancing.host_type(event.payload[:connection])
            increment_db_host_type_counters(host_type, event)
            observe_db_host_type_duration(host_type, event)
          end
        end

        def self.db_counter_payload
          return {} unless Gitlab::SafeRequestStore.active?

          counters = DB_COUNTERS
          counters += DB_LOAD_BALANCING_COUNTERS if Gitlab::Database::LoadBalancing.enable?
          counters.map do |counter|
            [counter, Gitlab::SafeRequestStore[counter].to_i]
          end.to_h
        end

        private

        def select_sql_command?(payload)
          payload[:sql].match(SQL_COMMANDS_WITH_COMMENTS_REGEX)
        end

        def increment_db_counters(event)
          payload = event.payload

          increment(:db_count)

          if payload.fetch(:cached, payload[:name] == 'CACHE')
            increment(:db_cached_count)
          end

          increment(:db_write_count) unless select_sql_command?(payload)
        end

        def increment_db_host_type_counters(host_type, event)
          payload = event.payload

          increment("db_#{host_type}_count".to_sym)

          if payload.fetch(:cached, payload[:name] == 'CACHE')
            increment("db_#{host_type}_cached_count".to_sym)
          end
        end

        def observe_db_duration(event)
          current_transaction&.observe(:gitlab_sql_duration_seconds, event.duration / 1000.0) do
            buckets [0.05, 0.1, 0.25]
          end
        end

        def observe_db_host_type_duration(host_type, event)
          current_transaction&.observe("gitlab_sql_#{host_type}_duration_seconds".to_sym, event.duration / 1000.0) do
            buckets [0.05, 0.1, 0.25]
          end
        end

        def increment(counter)
          current_transaction&.increment("gitlab_transaction_#{counter}_total".to_sym, 1)

          if Gitlab::SafeRequestStore.active?
            Gitlab::SafeRequestStore[counter] = Gitlab::SafeRequestStore[counter].to_i + 1
          end
        end

        def current_transaction
          ::Gitlab::Metrics::Transaction.current
        end
      end
    end
  end
end
