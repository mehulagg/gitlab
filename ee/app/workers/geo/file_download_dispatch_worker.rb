module Geo
  class FileDownloadDispatchWorker < Geo::Scheduler::Secondary::SchedulerWorker
    include CronjobQueue

    private

    def max_capacity
      current_node.files_max_capacity
    end

    def schedule_job(object_type, object_db_id)
      job_id = FileDownloadWorker.perform_async(object_type, object_db_id)

      { id: object_db_id, type: object_type, job_id: job_id } if job_id
    end

    def attachments_finder
      @attachments_finder ||= AttachmentRegistryFinder.new(current_node: current_node)
    end

    def file_registry_finder
      @file_registry_finder ||= FileRegistryFinder.new(current_node: current_node)
    end

    def lfs_objects_finder
      @lfs_objects_finder ||= LfsObjectRegistryFinder.new(current_node: current_node)
    end

    def job_artifacts_finder
      @job_artifacts_finder ||= JobArtifactRegistryFinder.new(current_node: current_node)
    end

    # Pools for new resources to be transferred
    #
    # @return [Array] resources to be transferred
    def load_pending_resources
      resources = find_unsynced_objects(batch_size: db_retrieve_batch_size)
      remaining_capacity = db_retrieve_batch_size - resources.count

      if remaining_capacity.zero?
        resources
      else
        resources + find_failed_upload_object_ids(batch_size: remaining_capacity)
      end
    end

    def find_unsynced_objects(batch_size:)
      lfs_object_ids = find_unsynced_lfs_objects_ids(batch_size: batch_size)
      attachment_ids = find_unsynced_attachments_ids(batch_size: batch_size)
      job_artifact_ids = find_unsynced_job_artifacts_ids(batch_size: batch_size)

      take_batch(lfs_object_ids, attachment_ids, job_artifact_ids)
    end

    def find_unsynced_lfs_objects_ids(batch_size:)
      lfs_objects_finder.find_unsynced_lfs_objects(batch_size: batch_size, except_file_ids: scheduled_file_ids(:lfs))
                        .pluck(:id)
                        .map { |id| [:lfs, id] }
    end

    def find_unsynced_attachments_ids(batch_size:)
      attachments_finder.find_unsynced_attachments(batch_size: batch_size, except_file_ids: scheduled_file_ids(Geo::FileService::DEFAULT_OBJECT_TYPES))
                        .pluck(:uploader, :id)
                        .map { |uploader, id| [uploader.sub(/Uploader\z/, '').underscore, id] }
    end

    def find_unsynced_job_artifacts_ids(batch_size:)
      job_artifacts_finder.find_unsynced_job_artifacts(batch_size: batch_size, except_artifact_ids: scheduled_file_ids(:job_artifact))
                        .pluck(:id)
                        .map { |id| [:job_artifact, id] }
    end

    def find_failed_upload_object_ids(batch_size:)
      file_ids = file_registry_finder.find_failed_file_registries(batch_size: batch_size)
                                     .pluck(:file_type, :file_id)
      artifact_ids = find_failed_artifact_ids(batch_size: batch_size)

      take_batch(file_ids, artifact_ids)
    end

    def find_failed_artifact_ids(batch_size:)
      job_artifacts_finder.find_failed_job_artifacts_registries.retry_due.limit(batch_size)
        .pluck(:artifact_id).map { |id| [:job_artifact, id] }
    end

    def scheduled_file_ids(file_types)
      file_types = Array(file_types)

      scheduled_jobs.select { |data| file_types.include?(data[:type]) }.map { |data| data[:id] }
    end
  end
end
