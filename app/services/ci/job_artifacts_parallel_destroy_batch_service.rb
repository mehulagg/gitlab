# frozen_string_literal: true

module Ci
  class JobArtifactsParallelDestroyBatchService
    include BaseServiceUtility
    include ::Gitlab::Utils::StrongMemoize

    # Runs a subprocess and applies handlers for stdout and stderr
    # Params:
    # +job_artifacts+:: Array of job artifacts for Object deletion
    # +pick_up_at+:: When to pick up for deletion of files
    def initialize(job_artifacts, pick_up_at: nil)
      @job_artifacts = job_artifacts
      @pick_up_at = pick_up_at
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def execute
      Ci::DeletedObject.transaction do
        Ci::DeletedObject.bulk_import(@job_artifacts, @pick_up_at)
        Ci::JobArtifact.where(id: @job_artifacts.map(&:id)).delete_all
        destroy_related_records(@job_artifacts)
      end

      # This is executed outside of the transaction because it depends on Redis
      update_project_statistics
      increment_monitoring_statistics(@job_artifacts.size)

      success(size: @job_artifacts.size)
    end
    # rubocop: enable CodeReuse/ActiveRecord

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
      destroyed_artifacts_counter.increment({}, size)
    end

    def destroyed_artifacts_counter
      strong_memoize(:destroyed_artifacts_counter) do
        name = :destroyed_job_artifacts_count_total
        comment = 'Counter of destroyed expired job artifacts'

        ::Gitlab::Metrics.counter(name, comment)
      end
    end
  end
end

Ci::JobArtifactsParallelDestroyBatchService.prepend_if_ee('EE::Ci::JobArtifactsParallelDestroyBatchService')
