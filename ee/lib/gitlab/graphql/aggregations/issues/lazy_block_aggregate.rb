# frozen_string_literal: true

module Gitlab
  module Graphql
    module Aggregations
      module Issues
        class LazyBlockAggregate
          attr_reader :issue_id, :lazy_state

          def initialize(query_ctx, issue_id)
            @issue_id = issue_id

            # Initialize the loading state for this query,
            # or get the previously-initiated state
            @lazy_state = query_ctx[:lazy_block_aggregate] ||= {
              pending_ids: Set.new,
              loaded_objects: {}
            }
            # Register this ID to be loaded later:
            @lazy_state[:pending_ids] << issue_id
          end

          # Return the loaded record, hitting the database if needed
          def block_aggregate
            # Check if the record was already loaded
            if @lazy_state[:pending_ids].present?
              load_records_into_loaded_objects
            end

            !!@lazy_state[:loaded_objects][@issue_id]
          end

          private

          def load_records_into_loaded_objects
            # The record hasn't been loaded yet, so
            # hit the database with all pending IDs to prevent N+1
            pending_ids = @lazy_state[:pending_ids].to_a
            blocked = IssueLink.blocked_issues_for_collection(pending_ids).compact.flatten

            blocked.each do |o|
              @lazy_state[:loaded_objects][o.blocked_issue_id] = true
            end

            @lazy_state[:pending_ids].clear
          end
        end
      end
    end
  end
end
