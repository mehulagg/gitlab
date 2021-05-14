# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # A job to set namespaces.traversal_ids in sub-batches, of all namespaces
    # without a parent and not already set.
    # rubocop:disable Style/Documentation
    class BackfillNamespaceTraversalIdsRoots
      class Namespace < ActiveRecord::Base
        include ::EachBatch

        self.table_name = 'namespaces'

        scope :base_query, -> { where(parent_id: nil) }
      end

      PAUSE_SECONDS = 0.1

      def perform(start_id, end_id, sub_batch_size)
        ranged_query = Namespace.base_query
          .where(id: start_id..end_id)
          .where("traversal_ids = '{}'")

        ranged_query.each_batch(of: sub_batch_size) do |sub_batch|
          first, last = sub_batch.pluck(Arel.sql('min(id), max(id)')).first
          sub_batch.unscoped.where(id: first..last).update_all('traversal_ids = ARRAY[id]')

          sleep PAUSE_SECONDS
        end

        mark_job_as_succeeded(start_id, end_id, sub_batch_size)
      end

      private

      def mark_job_as_succeeded(*arguments)
        Gitlab::Database::BackgroundMigrationJob.mark_all_as_succeeded(
          'BackfillNamespaceTraversalIdsRoots',
          arguments
        )
      end
    end
  end
end
