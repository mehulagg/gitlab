# frozen_string_literal: true

module Resolvers
  module Clusters
    class AgentResolver < AgentsResolver
      argument :name, GraphQL::STRING_TYPE,
               required: true,
               description: 'Name of the cluster agent'
    end
  end
end
