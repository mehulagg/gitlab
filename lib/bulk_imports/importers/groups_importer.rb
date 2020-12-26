# frozen_string_literal: true

module BulkImports
  module Importers
    class GroupsImporter
      ENTITY_JOB_WAIT_TIME = 20

      def initialize(bulk_import_id)
        @bulk_import = BulkImport.find(bulk_import_id)
      end

      def execute
        bulk_import.start! unless bulk_import.started?

        if entities_to_import.empty?
          bulk_import.finish!
        else
          waiter = ::Gitlab::JobWaiter.new

          entities_to_import.each do |entity|
            BulkImports::EntityWorker.perform_async(entity.id, waiter.key)

            waiter.jobs_remaining += 1
          end

          wait_for_jobs

          # A new BulkImportWorker job is enqueued to either
          #   - Process the new BulkImports::Entity created for the subgroups
          #   - Or to mark the `bulk_import` as finished.
          BulkImportWorker.perform_async(bulk_import.id)
        end
      end

      private

      attr_reader :bulk_import

      def entities_to_import
        @entities_to_import ||= bulk_import.entities.with_status(:created)
      end

      def wait_for_jobs(waiter)
        waiter.wait(ENTITY_JOB_WAIT_TIME)

        if waiter.jobs_remaining > 0
          wait_for_jobs(waiter)
        end
      end
    end
  end
end
