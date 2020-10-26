# frozen_string_literal: true

module Types
  module Clusters
    class AgentTokenType < BaseObject
      graphql_name 'ClusterAgentToken'

      authorize :admin_cluster

      connection_type_class(Types::CountableConnectionType)

      field :cluster_agent,
            Types::Clusters::AgentType,
            description: 'Cluster agent this token is associated with',
            null: true,
            resolve: -> (token, _args, _context) { Gitlab::Graphql::Loaders::BatchModelLoader.new(::Clusters::Agent, token.agent_id).find }

      field :created_at,
            Types::TimeType,
            null: true,
            description: 'Timestamp the token was created'

      field :id,
            ::Types::GlobalIDType[::Clusters::AgentToken],
            null: false,
            description: 'Global ID of the token'
    end
  end
end
