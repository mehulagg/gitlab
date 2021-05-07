# frozen_string_literal: true

module Clusters
  class DeployableAgentsFinder
    def initialize(project)
      @project = project
    end

    def execute
      return ::Clusters::Agent.none unless allowed?

      project.cluster_agents.ordered_by_name
    end

    private

    attr_reader :project

    def allowed?
      project.licensed_feature_available?(:cluster_agents)
    end
  end
end
