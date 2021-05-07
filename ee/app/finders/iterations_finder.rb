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

  class << self
    def params_for_parent(parent, include_ancestors: false)
      case parent
      when Group
        if include_ancestors
          { group_ids: parent.self_and_ancestors.select(:id) }
        else
          { group_ids: parent.id }
        end
      when Project
        if include_ancestors && parent.parent_id.present?
          { group_ids: parent.parent.self_and_ancestors.select(:id), project_ids: parent.id }
        else
          { project_ids: parent.id }
        end
      else
        raise ArgumentError, 'Invalid parent class. Only Project and Group are supported.'
      end
    end
  end

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
    items = by_iteration_cadences(items)

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
    return items unless params[:id].present?

    items.id_in(params[:id])
  end

  def by_iid(items)
    params[:iid].present? ? items.iid_in(params[:iid]) : items
  end

  def by_title(items)
    return items unless params[:title].present?

    items.with_title(params[:title])
  end

  def by_search_title(items)
    return items unless params[:search_title].present?

    items.search_title(params[:search_title])
  end

  def by_state(items)
    return items unless params[:state].present?

    Iteration.filter_by_state(items, params[:state])
  end

  def by_iteration_cadences(items)
    return items unless params[:iteration_cadence_ids].present?

    items.by_iteration_cadence_ids(params[:iteration_cadence_ids])
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def order(items)
    order_statement = Gitlab::Database.nulls_last_order('due_date', 'ASC')
    items.reorder(order_statement).order(:title)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
