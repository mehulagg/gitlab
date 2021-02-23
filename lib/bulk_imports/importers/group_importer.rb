# frozen_string_literal: true

module BulkImports
  module Importers
    class GroupImporter

      class Finisher
        def initialize(context)
          @context = context
        end

        def run
          @context.entity.finish!
        end
      end

      def initialize(entity)
        @entity = entity
      end

      def execute
        pipelines.each do |stage_name, pipelines|
          Array.wrap(pipelines).each do |pipeline|
            entity.pipeline_statuses.create!(
              pipeline_name: pipeline.name,
              stage_name: stage_name
            )
          end
        end

        entity.pipeline_statuses.create!(
          pipeline_name: 'BulkImports::Importers::GroupImporter',
          stage_name: :zz_last
        )

        BulkImports::PipelineWorker.perform_async(entity.id)
      end

      private

      attr_reader :entity

      def pipelines
        {
          stage_1: BulkImports::Groups::Pipelines::GroupPipeline,
          stage_2: [
            BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline,
            BulkImports::Groups::Pipelines::MembersPipeline,
            BulkImports::Groups::Pipelines::LabelsPipeline
          ]
        }
      end
    end
  end
end

BulkImports::Importers::GroupImporter.prepend_if_ee('EE::BulkImports::Importers::GroupImporter')
