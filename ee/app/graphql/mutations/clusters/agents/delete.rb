# frozen_string_literal: true

module Mutations
  module Clusters
    module Agents
      class Delete < BaseMutation
        graphql_name 'ClusterAgentDelete'

        authorize :admin_cluster

        argument :id,
                 ::Types::GlobalIDType[::Clusters::Agent],
                 required: true,
                 description: 'Global id of the cluster agent that will be deleted'

        def resolve(id:)
          cluster_agent = authorized_find!(id: id)
          result = ::Clusters::Agents::DeleteService
            .new(container: cluster_agent.project, current_user: current_user)
            .execute(cluster_agent)

          {
            errors: Array.wrap(result.message)
          }
        end

        private

        def find_object(id:)
          GitlabSchema.find_by_gid(id)
        end
      end
    end
  end
end
