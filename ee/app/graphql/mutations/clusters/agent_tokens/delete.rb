# frozen_string_literal: true

module Mutations
  module Clusters
    module AgentTokens
      class Delete < BaseMutation
        graphql_name 'ClusterAgentTokenDelete'

        authorize :admin_cluster

        argument :id,
                 ::Types::GlobalIDType[::Clusters::AgentToken],
                 required: true,
                 description: 'Global ID of the cluster agent token that will be deleted'

        def resolve(id:)
          token = authorized_find!(id: id)
          token.destroy

          { errors: errors_on_object(token) }
        end

        private

        def find_object(id:)
          GitlabSchema.find_by_gid(id)
        end
      end
    end
  end
end
