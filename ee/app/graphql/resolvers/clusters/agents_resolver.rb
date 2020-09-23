# frozen_string_literal: true

module Resolvers
  module Clusters
    class AgentsResolver < BaseResolver
      include LooksAhead

      type Types::Clusters::AgentType, null: true

      alias_method :project, :object

      def resolve_with_lookahead(**args)
        apply_lookahead(
          ::Clusters::AgentsFinder
            .new(project, context[:current_user], params: args)
            .execute
        )
      end

      private

      def preloads
        { tokens: :agent_tokens }
      end
    end
  end
end
