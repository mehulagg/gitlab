# frozen_string_literal: true

module Clusters
  module AgentTokens
    class CreateService < ::BaseContainerService
      def execute(cluster_agent)
        return error_feature_not_available unless container.feature_available?(:cluster_agents)
        return error_no_permissions unless current_user.can?(:create_cluster, container)

        token = ::Clusters::AgentToken.new(agent: cluster_agent)

        if token.save
          ServiceResponse.success(payload: { secret: token.token, token: token })
        else
          ServiceResponse.error(message: token.errors.full_messages)
        end
      end

      private

      def error_feature_not_available
        ServiceResponse.error(message: s_('ClusterAgent|This feature is only available for premium plans'))
      end

      def error_no_permissions
        ServiceResponse.error(message: s_('ClusterAgent|User has insufficient permissions to create a token for this project'))
      end
    end
  end
end
