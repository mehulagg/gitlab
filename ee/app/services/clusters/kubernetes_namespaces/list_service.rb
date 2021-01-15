# frozen_string_literal: true
module Clusters
  module KubernetesNamespaces
    class ListService
      LIMIT = 100

      def initialize(project:, environment_id: nil)
        @project = project
        @environment_id = environment_id
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def execute
        if @environment_id
          ::Clusters::KubernetesNamespace.where(environment: @project.environments.id_in(@environment_id))
        else
          ::Clusters::KubernetesNamespace.where(environment: @project.environments.available.at_most(LIMIT))
        end.pluck('clusters_kubernetes_namespaces.namespace').uniq
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
