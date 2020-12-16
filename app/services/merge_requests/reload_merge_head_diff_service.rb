# frozen_string_literal: true

module MergeRequests
  class ReloadMergeHeadDiffService
    def initialize(merge_request)
      @merge_request = merge_request
    end

    def execute
      MergeRequestDiff.transaction do
        merge_request.merge_head_diff&.destroy!

        # n+1: https://gitlab.com/gitlab-org/gitlab-foss/issues/37435
        Gitlab::GitalyClient.allow_n_plus_1_calls do
          merge_request.create_merge_head_diff!
          merge_request.reload_merge_head_diff
        end
      end
    end

    private

    attr_reader :merge_request
  end
end
