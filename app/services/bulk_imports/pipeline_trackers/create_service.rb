# frozen_string_literal: true

module BulkImports
  module PipelineTrackers
    class CreateService
      def initialize(entity)
        @entity = entity
      end

      def execute
        BulkImports::Stage.each do |stage, pipeline|
          @entity.trackers.create!(
            stage: stage,
            pipeline_name: pipeline
          )
        end
      end
    end
  end
end
