# frozen_string_literal: true
module MergeTrains
  # This class is to refresh all merge requests on the given merge train.
  #
  # It performs a sequential update on all merge requests on the train.
  # In order to prevent concurrent updates by multiple sidekiq jobs,
  # the process attempts to obtain an exclusive lock at first.
  # If the process successfully obtains the lock, the sequential refresh will be executed in this sidekiq job.
  # If the process failed to obtain the lock, the refresh will be performed after the current process has finished.
  class RefreshMergeRequestsService < BaseService
    include ::Gitlab::ExclusiveLeaseHelpers
    include ::Gitlab::Utils::StrongMemoize

    DEFAULT_CONCURRENCY = 20.freeze
    TRAIN_PROCECCING_LOCK_TIMEOUT = 15.minutes

    ##
    # merge_train ... A merge train metadata of a merge request.
    def execute(merge_train)
      @merge_train = merge_train

      queue = Gitlab::BatchPopQueueing.new('merge_trains', queue_id)
      result = queue.safe_execute([merge_train.merge_request.id], lock_timeout: TRAIN_PROCECCING_LOCK_TIMEOUT) do |items|
        unsafe_refresh
      end

      if result[:status] == :finished && result[:new_items].present?
        AutoMergeProcessWorker.perform_async(merge_train.first.merge_request)
      end
    end

    private

    attr_reader :merge_train

    def unsafe_refresh
      require_next_recreate = false

      merge_train.all(limit: DEFAULT_CONCURRENCY).each do |train|
        result = MergeTrains::RefreshMergeRequestService
          .new(train.target_project, train.user,
               require_recreate: require_next_recreate)
          .execute(train.merge_request)

        require_next_recreate = (result[:status] == :error || result[:pipeline_created])
      end
    end

    def queue_id
      "#{merge_train.target_project_id}:#{merge_train.target_branch}"
    end
  end
end
