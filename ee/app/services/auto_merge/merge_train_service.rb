# frozen_string_literal: true

module AutoMerge
  class MergeTrainService < AutoMerge::BaseService
    def execute(merge_request)
      merge_request.build_merge_train(user: current_user,
                                      target_project: merge_request.target_project,
                                      target_branch: merge_request.target_branch)

      super do
        SystemNoteService.merge_train(merge_request, project, current_user, merge_request.merge_train)
      end
    end

    def process(merge_request)
      return unless merge_request.on_train?

      ::MergeTrains::RefreshMergeRequestsService.new(project, nil).execute(merge_request)
    end

    def cancel(merge_request)
      # Before dropping a merge request from a merge train, get the next
      # merge request in order to refresh it later.
      next_merge_request = merge_request.merge_train&.next

      super do
        if merge_request.merge_train&.destroy
          SystemNoteService.cancel_merge_train(merge_request, project, current_user)
          next_merge_request.merge_train.outdate_pipeline if next_merge_request
        end
      end
    end

    def abort(merge_request, reason, process_next: true)
      # Before dropping a merge request from a merge train, get the next
      # merge request in order to refresh it later.
      next_merge_request = merge_request.merge_train&.next

      super(merge_request, reason) do
        if merge_request.merge_train&.destroy
          SystemNoteService.abort_merge_train(merge_request, project, current_user, reason)
          next_merge_request.merge_train.outdate_pipeline if next_merge_request && process_next
        end
      end
    end

    def available_for?(merge_request)
      super do
        merge_request.project.merge_trains_enabled? &&
          can_add_to_merge_train?(merge_request) &&
          merge_request.actual_head_pipeline&.complete?
      end
    end
  end
end
