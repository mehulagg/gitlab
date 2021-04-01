# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    module BackfillTraversalIds
      # A job to set namespaces.traversal_ids in sub-batches, of all namespaces
      # without a parent and not already set.
      class BackfillRoots
        BASE_QUERY = BackgroundMigration::BackfillTraversalIds::Namespace
          .where('parent_id IS NULL')
          .where('traversal_ids IS NULL')
        PAUSE_SECONDS = 2

        def perform(start_id, end_id, sub_batch_size)
          ranged_query = BASE_QUERY.where(id: start_id..end_id)
          ranged_query.each_batch(of: sub_batch_size) do |sub_batch|
            sub_batch.update_all('traversal_ids = ARRAY[id]')
            sleep PAUSE_SECONDS
          end

          mark_job_as_succeeded(start_id, end_id, sub_batch_size)
        end
      end

      private

      def mark_job_as_succeeded(*arguments)
        Gitlab::Database::BackgroundMigrationJob.mark_all_as_succeeded(
          'BackfillTraversalIds::BackfillRoots',
          arguments
        )
      end
    end
  end
end
