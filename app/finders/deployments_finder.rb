# frozen_string_literal: true

class DeploymentsFinder
  attr_reader :project_or_group, :params

  ALLOWED_SORT_VALUES = %w[id iid created_at updated_at finished_at ref].freeze
  DEFAULT_SORT_VALUE = 'id'

  ALLOWED_SORT_DIRECTIONS = %w[asc desc].freeze
  DEFAULT_SORT_DIRECTION = 'asc'

  def initialize(project_or_group, params = {})
    @project_or_group = project_or_group
    @params = params
  end

  def execute
    items = init_collection
    items = by_updated_at(items)
    items = by_finished_at(items)
    items = by_environment(items)
    items = by_status(items)
    items = sort(items) if should_sort?

    items
  end

  private

  def init_collection
    if project_or_group.is_a?(Project)
      # rubocop: disable CodeReuse/ActiveRecord
      project_or_group
        .deployments
        .includes(
          :user,
          environment: [],
          deployable: {
            job_artifacts: [],
            pipeline: {
              project: {
                route: [],
                namespace: :route
              }
            },
            project: {
              namespace: :route
            }
          }
        )
      # rubocop: enable CodeReuse/ActiveRecord
    else
      Deployment.for_projects(project_or_group.all_projects)
    end
  end

  def should_sort?
    return true if project_or_group.is_a?(Project)

    project_or_group.is_a?(Group) &&
      Feature.enabled?(:dora4_sorted_group_deployment_frequency)
  end

  def sort(items)
    # rubocop: disable CodeReuse/ActiveRecord
    items.order(sort_params)
    # rubocop: enable CodeReuse/ActiveRecord
  end

  def by_updated_at(items)
    items = items.updated_before(params[:updated_before]) if params[:updated_before].present?
    items = items.updated_after(params[:updated_after]) if params[:updated_after].present?

    items
  end

  def by_finished_at(items)
    items = items.finished_before(params[:finished_before]) if params[:finished_before].present?
    items = items.finished_after(params[:finished_after]) if params[:finished_after].present?

    items
  end

  def by_environment(items)
    if params[:environment].present?
      items.for_environment_name(params[:environment])
    else
      items
    end
  end

  def by_status(items)
    return items unless params[:status].present?

    unless Deployment.statuses.key?(params[:status])
      raise ArgumentError, "The deployment status #{params[:status]} is invalid"
    end

    items.for_status(params[:status])
  end

  def sort_params
    order_by = ALLOWED_SORT_VALUES.include?(params[:order_by]) ? params[:order_by] : DEFAULT_SORT_VALUE
    order_direction = ALLOWED_SORT_DIRECTIONS.include?(params[:sort]) ? params[:sort] : DEFAULT_SORT_DIRECTION

    { order_by => order_direction }.tap do |sort_values|
      sort_values['id'] = 'desc' if sort_values['updated_at']
      sort_values['id'] = sort_values.delete('created_at') if sort_values['created_at'] # Sorting by `id` produces the same result as sorting by `created_at`
    end
  end
end
