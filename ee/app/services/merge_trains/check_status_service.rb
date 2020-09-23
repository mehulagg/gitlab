# frozen_string_literal: true

module MergeTrains
  class CheckStatusService < BaseService
    def execute(target_project, target_branch, newrev)
      return unless target_project.merge_trains_enabled?

      # If the new revision doesn't exist in the merge train history,
      # that means there was an unexpected commit came from out of merge train cycle.
      unless MergeTrain.sha_exists_in_history?(target_project.id, target_branch, newrev)
        merge_request = MergeTrain.first_in_train(target_project.id, target_branch)
        merge_request.merge_train.outdate_pipeline if merge_request
      end
    end
  end
end
