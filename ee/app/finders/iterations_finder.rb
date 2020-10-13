# frozen_string_literal: true

# Search for iterations
#
# params - Hash
#   project_ids: Array of project ids or single project id or ActiveRecord relation.
#   group_ids: Array of group ids or single group id or ActiveRecord relation.
#   order - Orders by field default due date asc.
#   title - Filter by title.
#   state - Filters by state.

class IterationsFinder
  include FinderMethods
  include TimeFrameFilter

  attr_reader :params, :current_user

  def initialize(current_user, params = {})
    @params = params
    @current_user = current_user
  end

  def execute
    filter_permissions

    items = Iteration.all
    items = by_id(items)
    items = by_iid(items)
    items = by_groups_and_projects(items)
    items = by_title(items)
    items = by_search_title(items)
    items = by_state(items)
    items = by_timeframe(items)

    order(items)
  end

  private

  def filter_permissions
    filter_allowed_projects
    filter_allowed_groups

    # Only allow either one project_id or one group_id when filtering by `iid`
    if params[:iid] && params.slice(:project_ids, :group_ids).keys.count > 1
      raise ArgumentError, 'You can specify only one scope if you use iid filter'
    end
  end

  def filter_allowed_projects
    return unless params[:project_ids].present?

    projects = Project.id_in(params[:project_ids])
    params[:project_ids] = Project.projects_user_can(projects, current_user, :read_iteration)
  end

  def filter_allowed_groups
    return unless params[:group_ids].present?

    groups = Group.id_in(params[:group_ids])

    params[:group_ids] = Group.groups_user_can(groups, current_user, :read_iteration)
  end

  def by_groups_and_projects(items)
    items.for_projects_and_groups(params[:project_ids], params[:group_ids])
  end

  def by_id(items)
    if params[:id]
      items.id_in(params[:id])
    else
      items
    end
  end

  def by_iid(items)
    params[:iid].present? ? items.iid_in(params[:iid]) : items
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
    Iteration.filter_by_state(items, params[:state])
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def order(items)
    order_statement = Gitlab::Database.nulls_last_order('due_date', 'ASC')
    items.reorder(order_statement).order(:title)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
