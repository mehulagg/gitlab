# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Stage
      class ImportGroupWorker # rubocop:disable Scalability/IdempotentWorker
        include ApplicationWorker
        include Gitlab::BulkImport::QueueOptions

        def perform(bulk_import_id, entity_id, waiter_key = nil)
          bulk_import = BulkImport.find(bulk_import_id)

          return notify_waiter(waiter_key) unless bulk_import

          Importer::GroupImporter.new(entity_id).execute

          notify_waiter(waiter_key)
        end

        private

        def notify_waiter(key = nil)
          JobWaiter.notify(key, jid) if key
        end
      end
    end
  end
end
