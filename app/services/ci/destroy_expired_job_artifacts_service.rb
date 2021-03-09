# frozen_string_literal: true

module Ci
  class DestroyExpiredJobArtifactsService
    include ::Gitlab::ExclusiveLeaseHelpers
    include ::Gitlab::LoopHelpers

    BATCH_SIZE = 100
    LOOP_TIMEOUT = 5.minutes
    LOOP_LIMIT = 1000
    EXCLUSIVE_LOCK_KEY = 'expired_job_artifacts:destroy:lock'
    LOCK_TIMEOUT = 6.minutes

    ##
    # Destroy expired job artifacts on GitLab instance
    #
    # This destroy process cannot run for more than 6 minutes. This is for
    # preventing multiple `ExpireBuildArtifactsWorker` CRON jobs run concurrently,
    # which is scheduled every 7 minutes.
    def execute
      in_lock(EXCLUSIVE_LOCK_KEY, ttl: LOCK_TIMEOUT, retries: 1) do
        return Ci::DestroyJobArtifactsInBatchesService.new(
          Ci::JobArtifact.expired_before(Time.current),
          destroy_locked: false,
          start_at: Time.current,
          loop_timeout: LOOP_TIMEOUT,
          loop_limit: LOOP_LIMIT,
          batch_size: BATCH_SIZE
        ).execute
      end
    end
  end
end
