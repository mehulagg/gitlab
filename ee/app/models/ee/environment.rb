# frozen_string_literal: true

module EE
  module Environment
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Utils::StrongMemoize

    prepended do
      # Returns environments where its latest deployment is to a cluster
      scope :deployed_to_cluster, -> (cluster) do
        environments = model.arel_table
        deployments = ::Deployment.arel_table
        later_deployments = ::Deployment.arel_table.alias('latest_deployments')
        join_conditions = later_deployments[:environment_id]
          .eq(deployments[:environment_id])
          .and(deployments[:id].lt(later_deployments[:id]))

        join = deployments
          .join(later_deployments, Arel::Nodes::OuterJoin)
          .on(join_conditions)

        model
          .joins(:successful_deployments)
          .joins(join.join_sources)
          .where(later_deployments[:id].eq(nil))
          .where(deployments[:cluster_id].eq(cluster.id))
          .where(deployments[:project_id].eq(environments[:project_id]))
      end

      scope :preload_for_cluster_environment_entity, -> do
        preload(
          last_deployment: [:deployable],
          project: [:route, { namespace: :route }]
        )
      end
    end

    def reactive_cache_updated
      super

      ::Gitlab::EtagCaching::Store.new.tap do |store|
        store.touch(
          ::Gitlab::Routing.url_helpers.project_environments_path(project, format: :json))

        store.touch(cluster_environments_etag_key) if cluster_environments_etag_key
      end
    end

    def cluster_environments_etag_key
      strong_memoize(:cluster_environments_key) do
        cluster = last_deployment&.cluster

        if cluster&.group_type?
          ::Gitlab::Routing.url_helpers.environments_group_cluster_path(cluster.group, cluster)
        elsif cluster&.instance_type?
          ::Gitlab::Routing.url_helpers.environments_admin_cluster_path(cluster)
        end
      end
    end

    def protected?
      project.protected_environment_by_name(name).present?
    end

    def protected_deployable_by_user?(user)
      project.protected_environment_accessible_to?(name, user)
    end

    def rollout_status
      return unless rollout_status_available?

      result = rollout_status_with_reactive_cache

      result || ::Gitlab::Kubernetes::RolloutStatus.loading
    end

    def ingresses
      return unless rollout_status_available?

      deployment_platform.ingresses(deployment_namespace)
    end

    def patch_ingress(ingress, data)
      return unless rollout_status_available?

      deployment_platform.patch_ingress(deployment_namespace, ingress, data)
    end

    private

    def rollout_status_available?
      has_terminals?
    end

    def rollout_status_with_reactive_cache
      with_reactive_cache do |data|
        deployment_platform.rollout_status(self, data)
      end
    end
  end
end
