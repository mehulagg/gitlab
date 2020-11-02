# frozen_string_literal: true

module Mutations
  module Clusters
    module Agents
      class Create < BaseMutation
        include ResolvesProject

        authorize :create_cluster

        graphql_name 'CreateClusterAgent'

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'Full path of the associated project for this cluster agent.'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'Name of the cluster agent.'

        field :cluster_agent,
              Types::Clusters::AgentType,
              null: true,
              description: 'Cluster agent created after mutation.'

        def resolve(project_path:, name:)
          project = authorized_find!(full_path: project_path)
          result = ::Clusters::Agents::CreateService.new(project, current_user).execute(name: name)

          {
            cluster_agent: result[:cluster_agent],
            errors: Array.wrap(result[:message])
          }
        end

        private

        def find_object(full_path:)
          resolve_project(full_path: full_path)
        end
      end
    end
  end
end
