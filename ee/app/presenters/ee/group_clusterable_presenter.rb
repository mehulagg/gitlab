# frozen_string_literal: true

module EE
  module GroupClusterablePresenter
    extend ::Gitlab::Utils::Override

    override :metrics_cluster_path
    def metrics_cluster_path(cluster, params = {})
      metrics_group_cluster_path(clusterable, cluster, params)
    end

    override :environments_cluster_path
    def environments_cluster_path(cluster)
      return super unless can_read_cluster_environments?

      environments_group_cluster_path(clusterable, cluster)
    end

    private

    def can_read_cluster_environments?
      can?(current_user, :read_cluster_environments, clusterable)
    end
  end
end
