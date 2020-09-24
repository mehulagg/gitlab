# frozen_string_literal: true

module Clusters
  class EnvironmentEntity < API::Entities::EnvironmentBasic
    include RequestAwareEntity

    expose :project, using: API::Entities::ProjectIdentity

    expose :last_deployment, using: Clusters::DeploymentEntity

    expose :environment_path do |environment|
      project_environment_path(environment.project, environment)
    end

    expose :logs_path, if: -> (*) { can_read_pod_logs? } do |environment|
      project_logs_path(environment.project, environment_name: environment.name)
    end

    expose :rollout_status, if: -> (*) { can_read_cluster_deployments? }, using: ::RolloutStatusEntity

    expose :updated_at

    private

    alias_method :environment, :object

    def current_user
      request.current_user
    end

    def can_read_cluster_deployments?
      can?(current_user, :read_cluster_environments, request.cluster)
    end

    def can_read_pod_logs?
      can?(current_user, :read_pod_logs, environment.project)
    end
  end
end
