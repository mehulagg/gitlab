# frozen_string_literal: true

# Import top level groups as part of separate sidekiq jobs.
# Any subgroups are handled within the same job.
module BulkImports
  module Importers
    class GroupsImporter
      def initialize(bulk_import_id)
        @bulk_import_id = bulk_import_id
      end

      def execute
        return unless bulk_import = BulkImport.find(@bulk_import_id)

        waiter = Gitlab::JobWaiter.new

        bulk_import.top_level_groups.each do |entity|
          BulkImports::ImportGroupWorker.perform_async(@bulk_import_id, entity.id, waiter.key)

          waiter.jobs_remaining += 1
        end

        waiter
      end
    end
  end
end
