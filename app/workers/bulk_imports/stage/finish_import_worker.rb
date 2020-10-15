# frozen_string_literal: true

module BulkImports
  module Stage
    class FinishImportWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include QueueOptions

      def perform(bulk_import_id)
        bulk_import = BulkImport.find(bulk_import_id)

        bulk_import.finish!
      end
    end
  end
end
