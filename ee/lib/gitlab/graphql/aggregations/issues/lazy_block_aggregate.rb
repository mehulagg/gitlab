# frozen_string_literal: true

module Gitlab
  module Graphql
    module Aggregations
      module Issues
        class LazyBlockAggregate
          include ::Gitlab::Graphql::Deferred

          attr_reader :issue_id, :lazy_state

          def initialize(query_ctx, issue_id, load_issue_objects: false, &block)
            @issue_id = issue_id
            @block = block

            # Initialize the loading state for this query,
            # or get the previously-initiated state
            @lazy_state = query_ctx[:lazy_block_aggregate] ||= {
              pending_ids: Set.new,
              loaded_objects: {}
            }
            @lazy_state[:user] ||= query_ctx[:current_user]
            # Register this ID to be loaded later:
            @lazy_state[:pending_ids] << issue_id
            # just need a truthy value
            @lazy_state[:load_issue_objects] ||= !!load_issue_objects
          end

          # Return the loaded record, hitting the database if needed
          def block_aggregate
            # Check if the record was already loaded
            if @lazy_state[:pending_ids].present?
              load_records_into_loaded_objects
            end

            result = blocked_issue_stat(@issue_id)

            @block.call(result) if @block
          end

          alias_method :execute, :block_aggregate

          private

          def load_records_into_loaded_objects
            # The record hasn't been loaded yet, so
            # hit the database with all pending IDs to prevent N+1
            pending_ids = @lazy_state[:pending_ids].to_a

            # if we want the blocking issues themselves (from any field), load them from the DB rather than just the count. And then we can just count them to get the count.
            if @lazy_state[:load_issue_objects]
              pending_ids.each do |pending_id|
                # using issue finder to filter out what the user can't see
                blocked_issue_objects = ::IssuesFinder.new(current_user).execute.where(id: IssueLink.blocking_issue_ids(pending_ids))
                @lazy_state[:loaded_objects][pending_id] ||= {}
                @lazy_state[:loaded_objects][pending_id][:issues] = blocked_issue_objects
              end
            else
              blocking_data = IssueLink.blocked_issues_for_collection(pending_ids).compact.flatten
              blocking_data.each do |blocked|
                blocked_issue_stat(blocked.blocked_issue_id)[:count] = blocked.count
              end
            end

            @lazy_state[:pending_ids].clear
          end

          def blocked_issue_stat(id)
            @lazy_state[:loaded_objects][id] ||= {}
          end

          def current_user
            @lazy_state[:current_user]
          end
        end
      end
    end
  end
end
