# frozen_string_literal: true

module Types
  module Clusters
    class AgentType < BaseObject
      graphql_name 'ClusterAgent'

      authorize :admin_cluster

      connection_type_class(Types::CountableConnectionType)

      field :created_at,
            Types::TimeType,
            null: true,
            description: 'Timestamp the cluster agent was created'

      field :id, GraphQL::ID_TYPE,
            null: false,
            description: 'ID of the cluster agent'

      field :name,
            GraphQL::STRING_TYPE,
            null: true,
            description: 'Name of the cluster agent'

      field :project, Types::ProjectType,
            description: 'The project this cluster agent is associated with',
            null: true,
            authorize: :read_project,
            resolve: -> (agent, args, context) { Gitlab::Graphql::Loaders::BatchModelLoader.new(Project, agent.project_id).find }

      field :tokens, Types::Clusters::AgentTokenType.connection_type,
            description: 'Tokens associated with the cluster agent',
            null: true,
            resolver: ::Resolvers::Clusters::AgentTokensResolver

      field :updated_at,
            Types::TimeType,
            null: true,
            description: 'Timestamp the cluster agent was updated'
    end
  end
end
