# frozen_string_literal: true

module Gitlab
  module Graphql
    module Aggregations
      module Vulnerabilities
        class LazyUserNotesCountAggregate
          include ::Gitlab::Graphql::Deferred

          attr_reader :vulnerability, :lazy_state

          def initialize(query_ctx, vulnerability)
            @vulnerability = vulnerability.respond_to?(:sync) ? vulnerability.sync : vulnerability

            # Initialize the loading state for this query,
            # or get the previously-initiated state
            @lazy_state = query_ctx[:lazy_user_notes_count_aggregate] ||= {
              pending_vulnerability_ids: Set.new,
              loaded_objects: {}
            }
            # Register this ID to be loaded later:
            @lazy_state[:pending_vulnerability_ids] << vulnerability.id
          end

          # Return the loaded record, hitting the database if needed
          def execute
            # Check if the record was already loaded
            if @lazy_state[:pending_vulnerability_ids].present?
              load_records_into_loaded_objects
            end

            @lazy_state[:loaded_objects][@vulnerability.id]
          end

          private

          def load_records_into_loaded_objects
            # The record hasn't been loaded yet, so
            # hit the database with all pending IDs to prevent N+1
            pending_vulnerability_ids = @lazy_state[:pending_vulnerability_ids].to_a
            counts = ::Note.user.count_for_vulnerability_id(pending_vulnerability_ids)

            pending_vulnerability_ids.each do |vulnerability_id|
              @lazy_state[:loaded_objects][vulnerability_id] = counts[vulnerability_id].to_i
            end

            @lazy_state[:pending_vulnerability_ids].clear
          end
        end
      end
    end
  end
end
