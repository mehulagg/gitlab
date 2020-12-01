# frozen_string_literal: true
module MergeTrains
  class RefreshMergeRequestsService < BaseService
    include ::Gitlab::ExclusiveLeaseHelpers
    include ::Gitlab::Utils::StrongMemoize

    DEFAULT_CONCURRENCY = 20

    ##
    # merge_request ... A merge request pointer in a merge train.
    #                   All the merge requests following the specified merge request will be refreshed.
    def execute(merge_request)
      @merge_request = merge_request

      return unless merge_request.on_train?

      queue = Gitlab::BatchPopQueueing.new('merge_trains', queue_id)

      result = queue.safe_execute([merge_request.id], lock_timeout: 15.minutes) do |items|
        logging("Successfuly obtained the exclusive lock. Found merge requests to be refreshed", merge_request_ids: items.map(&:to_i))

        first_merge_request = get_first_in_train(items)
        unsafe_refresh(first_merge_request)
      end

      if result[:status] == :enqueued
        logging("This merge request was enqueued because the exclusive lock is obtained by the other process.")
      end

      if result[:status] == :finished && result[:new_items].present?
        logging("Found more merge requests to be refreshed", merge_request_ids: result[:new_items].map(&:to_i))

        get_first_in_train(result[:new_items]).try do |first_merge_request|
          logging("Rescheduled to refresh the merge train from", merge_request_ids: [first_merge_request.id])

          AutoMergeProcessWorker.perform_async(first_merge_request.id)
        end
      end
    end

    private

    attr_reader :merge_request

    # TODO:
    # As we changed the process flow to refresh merge requests from the begnning always,
    # we don't use the `items` argument anymore.
    # We should refactor the current logic to make this class more readable.
    # See https://gitlab.com/gitlab-org/gitlab/-/issues/281065
    def get_first_in_train(items)
      MergeTrain.first_in_train(merge_request.target_project, merge_request.target_branch)
    end

    def unsafe_refresh(first_merge_request)
      require_next_recreate = false

      following_merge_requests_from(first_merge_request).each do |following_mr|
        logging("Started refreshing", merge_request_ids: [following_mr.id])

        break if following_mr.merge_train.index >= max_concurrency

        result = MergeTrains::RefreshMergeRequestService
          .new(following_mr.project, following_mr.merge_user,
               require_recreate: require_next_recreate)
          .execute(following_mr)

        require_next_recreate = (result[:status] == :error || result[:pipeline_created])
      end
    end

    def following_merge_requests_from(first_merge_request)
      first_merge_request.merge_train.all_next.to_a.unshift(first_merge_request)
    end

    def queue_id
      "#{merge_request.target_project_id}:#{merge_request.target_branch}"
    end

    def max_concurrency
      strong_memoize(:max_concurrency) do
        DEFAULT_CONCURRENCY
      end
    end

    def logging(message, extra = {})
      return unless Feature.enabled?(:ci_merge_train_logging, merge_request.project)

      Sidekiq.logger.info(
        { class: self.class.to_s, args: [merge_request.id.to_s], message: message }.merge(extra)
      )
    end
  end
end
