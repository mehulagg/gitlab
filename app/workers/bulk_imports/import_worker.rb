# frozen_string_literal: true

module BulkImports
  class ImportWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include QueueOptions

    def perform(bulk_import_id)
      # Any preprocessing goes here

      Stage::ImportGroupsWorker.perform_async(bulk_import_id)
    end
  end
end
