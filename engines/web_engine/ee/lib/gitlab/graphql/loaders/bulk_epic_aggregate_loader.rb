# frozen_string_literal: true

module Gitlab
  module Graphql
    module Loaders
      class BulkEpicAggregateLoader
        include ::Gitlab::Graphql::Aggregations::Epics::Constants

        MAXIMUM_LOADABLE = 100_001

        attr_reader :target_epic_ids, :results

        # This class retrieves each epic and its child epics recursively
        # It allows us to recreate the epic tree structure in POROs
        def initialize(epic_ids:)
          @results = {}
          @target_epic_ids = epic_ids
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def execute
          return {} unless target_epic_ids

          # We do a left outer join in order to capture epics with no issues
          # This is so we can aggregate the epic counts for every epic
          raw_results = ::Gitlab::ObjectHierarchy.new(Epic.where(id: target_epic_ids)).base_and_descendants
            .left_joins(epic_issues: :issue)
            .group("issues.state_id", "epics.id", "epics.iid", "epics.parent_id", "epics.state_id")
            .select("epics.id, epics.iid, epics.parent_id, epics.state_id AS epic_state_id, issues.state_id AS issues_state_id, COUNT(issues) AS issues_count, SUM(COALESCE(issues.weight, 0)) AS issues_weight_sum")
            .limit(MAXIMUM_LOADABLE)

          raw_results = raw_results.map { |record| record.attributes.with_indifferent_access }

          raise ArgumentError.new("There are too many records to load. Please select fewer epics or contact your administrator.") if raw_results.count == MAXIMUM_LOADABLE

          @results = raw_results.group_by { |record| record[:id] }
        end
        # rubocop: enable CodeReuse/ActiveRecord
      end
    end
  end
end
