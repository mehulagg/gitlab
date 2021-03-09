# frozen_string_literal: true

module Ci
  class JobArtifactsDestroyBatchService
    include BaseServiceUtility
    include ::Gitlab::Utils::StrongMemoize

    MAX_JOB_ARTIFACT_BATCH_SIZE = 1_000

    # Danger: Not for direct use and is meant to be called from a service that sends job_artifacts in batches
    #
    # Adds the passed batch of job artifacts to the `ci_deleted_objects` table
    # for asyncronous destruction of the objects in Object Storage via the `Ci::DeleteObjectsService`
    # and then deletes the batch of related `ci_job_artifacts` records.
    # Params:
    # +job_artifacts+:: A relation of job artifacts to destroy (fewer than MAX_JOB_ARTIFACT_BATCH_SIZE)
    # +pick_up_at+:: When to pick up for deletion of files
    # Returns:
    # +Hash+:: A hash with status and destroyed_artifacts_count keys
    def initialize(job_artifacts, pick_up_at: nil)
      @artifacts_count = job_artifacts.count

      raise ArgumentError if @artifacts_count > MAX_JOB_ARTIFACT_BATCH_SIZE

      @job_artifacts = job_artifacts.with_destroy_preloads.to_a
      @pick_up_at = pick_up_at
      @destroyed_artifacts_count = 0
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def execute
      return success_response if @job_artifacts.empty?

      Ci::DeletedObject.transaction do
        Ci::DeletedObject.bulk_import(@job_artifacts, @pick_up_at)
        Ci::JobArtifact.id_in(@job_artifacts.map(&:id)).delete_all
        destroy_related_records(@job_artifacts)
      end

      # This is executed outside of the transaction because it depends on Redis
      update_project_statistics
      increment_monitoring_statistics(@artifacts_count)

      success_response
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    # This method is implemented in EE and it must do only database work
    def destroy_related_records(artifacts); end

    def update_project_statistics
      artifacts_by_project = @job_artifacts.group_by(&:project)
      artifacts_by_project.each do |project, artifacts|
        delta = -artifacts.sum { |artifact| artifact.size.to_i }
        ProjectStatistics.increment_statistic(
          project, Ci::JobArtifact.project_statistics_name, delta)
      end
    end

    def increment_monitoring_statistics(size)
      metrics.increment_destroyed_artifacts(size)
    end

    def metrics
      @metrics ||= ::Gitlab::Ci::Artifacts::Metrics.new
    end

    def success_response
      success(destroyed_artifacts_count: @artifacts_count)
    end
  end
end

Ci::JobArtifactsDestroyBatchService.prepend_if_ee('EE::Ci::JobArtifactsDestroyBatchService')
