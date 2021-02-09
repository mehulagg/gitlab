# frozen_string_literal: true

module BulkImports
  module Importers
    class GroupImporter
      class EntityFinisher
        def run(context)
          context.entity.finish!
        end
      end

      def initialize(entity)
        @entity = entity
      end

      def execute
        BulkImports::StageWorker.perform_async(entity.id, stages)
      end

      private

      attr_reader :entity

      def stages
        [
          BulkImports::Groups::Pipelines::GroupPipeline,
          [
            BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline,
            BulkImports::Groups::Pipelines::LabelsPipeline
          ],
          ::BulkImports::Importers::GroupImporter::EntityFinisher
        ]
      end
    end
  end
end

BulkImports::Importers::GroupImporter.prepend_if_ee('EE::BulkImports::Importers::GroupImporter')
