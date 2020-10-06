# frozen_string_literal: true

module Gitlab
  module BulkImport
    class ImportWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include Gitlab::BulkImport::QueueOptions

      def perform(bulk_import_id)
        # Any preprocessing goes here

        Stage::ImportGroupsWorker.perform_async(bulk_import_id)
      end
    end
  end
end
