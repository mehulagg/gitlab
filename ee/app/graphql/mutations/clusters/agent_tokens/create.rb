# frozen_string_literal: true

module Mutations
  module Clusters
    module AgentTokens
      class Create < BaseMutation
        graphql_name 'ClusterAgentTokenCreate'

        authorize :create_cluster

        argument :cluster_agent_id,
                 ::Types::GlobalIDType[::Clusters::Agent],
                 required: true,
                 description: 'Global ID of the cluster agent that will be associated with the new token'

        field :secret,
              GraphQL::STRING_TYPE,
              null: true,
              description: "Token secret value. Make sure you save it - you won't be able to access it again"

        field :token,
              Types::Clusters::AgentTokenType,
              null: true,
              description: 'Token created after mutation'

        def resolve(cluster_agent_id:)
          cluster_agent = authorized_find!(id: cluster_agent_id)

          result = ::Clusters::AgentTokens::CreateService
            .new(container: cluster_agent.project, current_user: current_user)
            .execute(cluster_agent)

          payload = result.payload

          {
           secret: payload[:secret],
           token: payload[:token],
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
