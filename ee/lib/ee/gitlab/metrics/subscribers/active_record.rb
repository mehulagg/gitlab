# frozen_string_literal: true

module EE
  module Gitlab
    module Metrics
      module Subscribers
        module ActiveRecord
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          DB_LOAD_BALANCING_COUNTERS = %i{
            db_replica_count db_replica_cached_count
            db_primary_count db_primary_cached_count
          }.freeze
          DB_LOAD_BALANCING_DURATIONS = %i{db_primary_duration_s db_replica_duration_s}.freeze

          class_methods do
            extend ::Gitlab::Utils::Override

            override :known_payload_keys
            def known_payload_keys
              super + DB_LOAD_BALANCING_COUNTERS
            end

            override :db_counter_payload
            def db_counter_payload
              super.tap do |payload|
                if ::Gitlab::SafeRequestStore.active? && ::Gitlab::Database::LoadBalancing.enable?
                  DB_LOAD_BALANCING_COUNTERS.each do |counter|
                    payload[counter] = ::Gitlab::SafeRequestStore[counter].to_i
                  end
                  DB_LOAD_BALANCING_DURATIONS.each do |duration|
                    payload[duration] = ::Gitlab::SafeRequestStore[duration].to_f.round(3)
                  end
                end
              end
            end
          end

          override :sql
          def sql(event)
            super

            return unless ::Gitlab::Database::LoadBalancing.enable?

            payload = event.payload
            return if ignored_query?(payload)

            db_role = ::Gitlab::Database::LoadBalancing.db_role_for_connection(payload[:connection])
            return if db_role.blank?

            increment_db_role_counters(db_role, payload)
            observe_db_role_duration(db_role, event)
          end

          private

          def increment_db_role_counters(db_role, payload)
            increment("db_#{db_role}_count".to_sym)
            increment("db_#{db_role}_cached_count".to_sym) if cached_query?(payload)
          end

          def observe_db_role_duration(db_role, event)
            observe("gitlab_sql_#{db_role}_duration_seconds".to_sym, event) do
              buckets ::Gitlab::Metrics::Subscribers::ActiveRecord::SQL_DURATION_BUCKET
            end

            duration = event.duration / 1000.0
            duration_key = "db_#{db_role}_duration_s".to_sym
            ::Gitlab::SafeRequestStore[duration_key] = (::Gitlab::SafeRequestStore[duration_key].presence || 0) + duration
          end
        end
      end
    end
  end
end
