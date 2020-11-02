# frozen_string_literal: true

module BulkImports
  module Importers
    class GroupImporter
      def initialize(entity)
        @entity = entity
      end

      def execute
        @entity.start!
        bulk_import = @entity.bulk_import
        configuration = bulk_import.configuration

        context = BulkImports::Pipeline::Context.new(
          current_user: bulk_import.user,
          entity: @entity,
          configuration: configuration
        )

        BulkImports::Groups::Pipelines::GroupPipeline.new.run(context)
        BulkImports::Groups::Pipelines::EpicsPipeline.new.run(context)
        BulkImports::Groups::Pipelines::SubgroupsPipeline.new.run(context)

        @entity.finish!
      end
    end
  end
end
