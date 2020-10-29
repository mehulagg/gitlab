# frozen_string_literal: true

module BulkImports
  module Importers
    class GroupsImporter
      def initialize(bulk_import_id)
        @bulk_import = BulkImport.find(bulk_import_id)
      end

      def execute
        @bulk_import.start

        if processable_entities.empty?
          @bulk_import.finish!
        else
          processable_entities.each do |entity|
            GroupImporter.new(entity).execute
          end

          # GroupImporter might create new entities for the subgroups
          BulkImportWorker.perform_async(@bulk_import.id)
        end
      end

      def processable_entities
        @entities ||= @bulk_import.entities.with_status(:created)
      end
    end
  end
end
