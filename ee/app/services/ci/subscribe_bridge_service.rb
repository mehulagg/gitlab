# frozen_string_literal: true

module Ci
  class SubscribeBridgeService < ::BaseService
    include ::Gitlab::Utils::StrongMemoize

    def execute(bridge)
      return unless bridge.upstream_project_path

      @bridge = bridge

      unless upstream_project
        return bridge.drop!(:upstream_bridge_project_not_found)
      end

      unless upstream_pipeline
        return bridge.skip!
      end

      unless can?(current_user, :read_pipeline, upstream_pipeline)
        return bridge.drop!(:insufficient_upstream_permissions)
      end

      bridge.update!(upstream_pipeline: upstream_pipeline)
      bridge.inherit_status_from_upstream!
    end

    private

    def upstream_project
      strong_memoize(:upstream_project) do
        @bridge.upstream_project
      end
    end

    def upstream_pipeline
      strong_memoize(:upstream_pipeline) do
        upstream_project.latest_pipeline(upstream_project.default_branch)
      end
    end
  end
end
