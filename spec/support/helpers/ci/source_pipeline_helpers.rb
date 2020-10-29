# frozen_string_literal: true

module Ci
  module SourcePipelineHelpers
    def create_source_pipeline(upstream, downstream, strategy: nil)
      traits = []
      traits << :strategy_depend if strategy == :depend

      bridge = create(:ci_bridge, *traits, pipeline: upstream)

      create(:ci_sources_pipeline,
             source_bridge: bridge,
             source_project: upstream.project,
             pipeline: downstream,
             project: downstream.project)
    end
  end
end
