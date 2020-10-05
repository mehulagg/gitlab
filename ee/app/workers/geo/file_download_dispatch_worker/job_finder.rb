# frozen_string_literal: true

module Geo
  class FileDownloadDispatchWorker # rubocop:disable Scalability/IdempotentWorker
    # This class is meant to be inherited, and is responsible for generating
    # batches of job arguments for FileDownloadWorker.
    #
    # The subclass should define
    #
    #   * registry_finder
    #   * EXCEPT_RESOURCE_IDS_KEY
    #   * RESOURCE_ID_KEY
    #   * FILE_SERVICE_OBJECT_TYPE
    #
    class JobFinder # rubocop:disable Scalability/IdempotentWorker
      include Gitlab::Utils::StrongMemoize

      attr_reader :scheduled_file_ids

      def initialize(scheduled_file_ids)
        @scheduled_file_ids = scheduled_file_ids
      end

      def find_jobs_never_attempted_sync(batch_size:)
        convert_registry_relation_to_job_args(
          registry_finder.find_registries_never_attempted_sync(**find_batch_params(batch_size))
        )
      end

      def find_jobs_needs_sync_again(batch_size:)
        convert_registry_relation_to_job_args(
          registry_finder.find_registries_needs_sync_again(**find_batch_params(batch_size))
        )
      end

      def find_jobs_synced_missing_on_primary(batch_size:)
        convert_registry_relation_to_job_args(
          registry_finder.find_retryable_synced_missing_on_primary_registries(**find_batch_params(batch_size))
        )
      end

      private

      def find_batch_params(batch_size)
        {
          :batch_size => batch_size,
          self.class::EXCEPT_RESOURCE_IDS_KEY => scheduled_file_ids
        }
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def convert_resource_relation_to_job_args(relation)
        relation.pluck(relation.model.arel_table[:id]).map! { |id| [self.class::FILE_SERVICE_OBJECT_TYPE.to_s, id] }
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def convert_registry_relation_to_job_args(relation)
        relation.pluck(self.class::RESOURCE_ID_KEY).map! { |id| [self.class::FILE_SERVICE_OBJECT_TYPE.to_s, id] }
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
