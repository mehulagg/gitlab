# frozen_string_literal: true

# Search for sprints
#
# params - Hash
#   project_ids: Array of project ids or single project id or ActiveRecord relation.
#   group_ids: Array of group ids or single group id or ActiveRecord relation.
#   order - Orders by field default due date asc.
#   title - Filter by title.
#   state - Filters by state.

class SprintsFinder
  include FinderMethods
  include TimeFrameFilter

  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def execute
    items = Sprint.all
    items = by_groups_and_projects(items)
    items = by_title(items)
    items = by_search_title(items)
    items = by_state(items)
    items = by_timeframe(items)

    order(items)
  end

  private

  def by_groups_and_projects(items)
    items.for_projects_and_groups(params[:project_ids], params[:group_ids])
  end

  def by_title(items)
    if params[:title]
      items.with_title(params[:title])
    else
      items
    end
  end

  def by_search_title(items)
    if params[:search_title].present?
      items.search_title(params[:search_title])
    else
      items
    end
  end

  def by_state(items)
    Sprint.filter_by_state(items, params[:state])
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def order(items)
    order_statement = Gitlab::Database.nulls_last_order('due_date', 'ASC')
    items.reorder(order_statement).order(:title)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
