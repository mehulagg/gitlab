# frozen_string_literal: true

module EE
  module ClustersHelper
    extend ::Gitlab::Utils::Override

    override :display_cluster_agents?
    def display_cluster_agents?(clusterable)
      clusterable.is_a?(Project) && clusterable.feature_available?(:cluster_agents) && included_in_gitlab_com_rollout?(clusterable)
    end

    private

    def included_in_gitlab_com_rollout?(project)
      ::Gitlab::Kas.included_in_gitlab_com_rollout?(project)
    end
  end
end
