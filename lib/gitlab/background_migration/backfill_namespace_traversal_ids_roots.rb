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
      end

      PAUSE_SECONDS = 0.1

      def self.base_query
        Namespace
          .where(parent_id: nil)
          .where("traversal_ids = '{}'")
      end

      def perform(start_id, end_id, sub_batch_size)
        ranged_query = self.class.base_query.where(id: start_id..end_id)
        ranged_query.each_batch(of: sub_batch_size) do |sub_batch|
          sub_batch.update_all('traversal_ids = ARRAY[id]')
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
