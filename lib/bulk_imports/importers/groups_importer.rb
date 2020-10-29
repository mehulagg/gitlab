# frozen_string_literal: true

module BulkImports
  module Importers
    class GroupsImporter
      def initialize(bulk_import_id)
        @bulk_import = BulkImport.find(bulk_import_id)
      end

      def execute
        @bulk_import.start! unless @bulk_import.started?

        if unfinished_entities.empty?
          @bulk_import.finish!
        else
          unfinished_entities.each do |entity|
            BulkImports::Importers::GroupImporter.new(entity).execute
          end

          # GroupImporter might create new entities for the subgroups
          # So we enqueue a new job to either import the new entities or
          # finish the bulk_import
          BulkImportWorker.perform_async(@bulk_import.id)
        end
      end

      def unfinished_entities
        @entities ||= @bulk_import.entities.with_status(:created)
      end
    end
  end
end
