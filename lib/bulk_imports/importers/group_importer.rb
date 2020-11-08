# frozen_string_literal: true

module BulkImports
  module Importers
    class GroupImporter
      def initialize(entity)
        @entity = entity
      end

      def execute
        entity.start!

        context = BulkImports::Pipeline::Context.new(entity)

        BulkImports::Groups::Pipelines::GroupPipeline.new.run(context)
        BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline.new.run(context)

        entity.finish!
      end

      private

      attr_reader :entity
    end
  end
end
