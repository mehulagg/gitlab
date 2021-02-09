# frozen_string_literal: true

module BulkImports
  module Importers
    class GroupImporter
      def initialize(entity)
        @entity = entity
      end

      def execute
        context = BulkImports::Pipeline::Context.new(entity)

        pipelines.each { |pipeline| pipeline.new.run(context) }
        importers.each { |importer| importer.new(entity).execute }

        entity.finish!
      end

      private

      attr_reader :entity

      def pipelines
        [
          BulkImports::Groups::Pipelines::GroupPipeline,
          BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline,
          BulkImports::Groups::Pipelines::LabelsPipeline
        ]
      end

      def importers
        []
      end
    end
  end
end

BulkImports::Importers::GroupImporter.prepend_if_ee('EE::BulkImports::Importers::GroupImporter')
