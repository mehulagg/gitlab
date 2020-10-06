# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Stage
      class FinishImportWorker # rubocop:disable Scalability/IdempotentWorker
        include ApplicationWorker

        private

        def import(bulk_import_id)
          # mark import as finished / failed
        end
      end
    end
  end
end
