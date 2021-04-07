# frozen_string_literal: true

class EnvironmentSerializer < BaseSerializer
  include WithPagination

  Item = Struct.new(:name, :size, :latest)

  entity EnvironmentEntity

  def within_folders
    tap { @itemize = true }
  end

  def itemized?
    @itemize
  end

  def represent(resource, opts = {})
    if itemized?
      items = itemize(resource)

      preload_for_deployment = [
        :user,
        :cluster,
        {
          deployable: [
            :user,
            pipeline: [
              :manual_actions,
              :scheduled_actions
            ]
            project: [
              :project_feature,
              :route,
              {
                namespace: :route
              }
            ]
          ]
        }
      ]

      ActiveRecord::Associations::Preloader.new.preload(items.map(&:latest),
        {
          last_deployment: preload_for_deployment,
          upcoming_deployment: preload_for_deployment,
          project: [:project_feature, :route, { namespace: :route }]
        }
      )

      items.map do |item|
        { name: item.name,
          size: item.size,
          latest: super(item.latest, opts) }
      end
    else
      super(resource, opts)
    end
  end

  private

  # rubocop: disable CodeReuse/ActiveRecord
  def itemize(resource)
    items = resource.order('folder ASC')
      .group('COALESCE(environment_type, name)')
      .select('COALESCE(environment_type, name) AS folder',
              'COUNT(*) AS size', 'MAX(id) AS last_id')

    # It makes a difference when you call `paginate` method, because
    # although `page` is effective at the end, it calls counting methods
    # immediately.
    items = @paginator.paginate(items) if paginated?

    environments = resource.where(id: items.map(&:last_id)).index_by(&:id)

    items.map do |item|
      Item.new(item.folder, item.size, environments[item.last_id])
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
