# frozen_string_literal: true
#
# Used to filter MergeRequests collections for compliance dashboard
#
# Arguments:
#   current_user - which user calls a class
#   params:
#     group_id: integer
#     preloads: array of associations to preload
#
class MergeRequestsComplianceFinder < MergeRequestsFinder
  def execute
    # rubocop: disable CodeReuse/ActiveRecord

    # This lateral query is used to get the single, latest
    # "MR merged" event PER project.
    lateral = Event
      .select(:created_at, :target_id)
      .where('projects.id = project_id')
      .merged_action
      .recent
      .limit(1)
      .to_sql

    query = projects_in_group
      .joins("JOIN LATERAL (#{lateral}) events ON true")
      .order('events.created_at DESC')
      .select('events.target_id as target_id') # The `target_id` of the `events` are the MR ids.

    ordered_events_cte = Gitlab::SQL::CTE.new(:ordered_events_cte, query)

    MergeRequest
      .with(ordered_events_cte.to_arel)
      .joins(inner_join_ordered_events_table(ordered_events_cte))
      .order(Arel.sql('array_position(ARRAY(SELECT target_id FROM ordered_events_cte), merge_requests.id)'))
      .preload(preloads)
    # rubocop: enable CodeReuse/ActiveRecord
  end

  private

  def inner_join_ordered_events_table(ordered_events_cte)
    merge_requests_table = MergeRequest.arel_table

    merge_requests_table
      .join(ordered_events_cte.table, Arel::Nodes::InnerJoin)
      .on(merge_requests_table[:id].eq(ordered_events_cte.table[:target_id]))
      .join_sources
  end

  def projects_in_group
    params.find_group_projects
  end

  def params
    finder_options = {
      include_subgroups: true,
      attempt_group_search_optimizations: true
    }
    super.merge(finder_options)
  end

  def preloads
    [
      :author,
      :approved_by_users,
      :metrics,
      source_project: :route,
      target_project: [:namespace, :compliance_management_framework],
      head_pipeline: [project: :project_feature]
    ]
  end
end
