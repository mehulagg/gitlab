# frozen_string_literal: true

module EE
  module ClustersHelper
    extend ::Gitlab::Utils::Override

    override :display_cluster_agents?
    def display_cluster_agents?(clusterable)
      clusterable.is_a?(Project) && clusterable.feature_available?(:cluster_agents)
    end
  end
end
