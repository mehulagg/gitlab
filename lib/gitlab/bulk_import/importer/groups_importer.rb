# frozen_string_literal: true

# Import top level groups as part of separate sidekiq jobs
# Any subgroups are handled within the same job
module Gitlab
  module BulkImport
    module Importer
      class GroupsImporter
        def initialize(bulk_import_id)
          @bulk_import_id = bulk_import_id
        end

        def execute
          return unless bulk_import = BulkImport.find(@bulk_import_id)

          waiter = JobWaiter.new

          bulk_import.top_level_groups.each do |entity|
            Gitlab::BulkImport::Importer::GroupImporter.perform_async(entity.id)

            waiter.jobs_remaining += 1
          end

          waiter
        end
      end
    end
  end
end
