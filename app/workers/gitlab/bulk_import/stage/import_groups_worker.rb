# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Stage
      class ImportGroupsWorker # rubocop:disable Scalability/IdempotentWorker
        include ApplicationWorker
        include Gitlab::BulkImport::QueueOptions

        def perform(bulk_import_id)
          waiter = Importer::GroupsImporter.new(bulk_import_id).execute

          AdvanceStageWorker.perform_async(
            bulk_import_id,
            { waiter.key => waiter.jobs_remaining },
            :finish
          )
        end
      end
    end
  end
end
