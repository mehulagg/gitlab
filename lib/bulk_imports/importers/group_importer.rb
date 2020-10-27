# frozen_string_literal: true

# Imports a top level group into a destination
# Optionally imports into parent group
# Entity must be of type: 'group' & have parent_id: nil
# Subgroups not handled yet
module BulkImports
  module Importers
    class GroupImporter
      def initialize(entity_id)
        @entity = BulkImports::Entity.find(entity_id)
        @bulk_import = @entity.bulk_import
        @config = @bulk_import.configuration
      end

      def execute
        context = BulkImports::Pipeline::Context.new(
          current_user: @bulk_import.user,
          entity: @entity,
          configuration: @config
        )

        BulkImports::Groups::Pipelines::GroupPipeline.new.run(context)
      end
    end
  end
end
