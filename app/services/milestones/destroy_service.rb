# frozen_string_literal: true

module Milestones
  class DestroyService < Milestones::BaseService
    def execute(milestone)
      milestone_mr_ids = milestone.merge_requests.to_a.collect(&:id)

      Milestone.transaction do
        update_params = { milestone: nil, skip_milestone_email: true }

        milestone.issues.each do |issue|
          Issues::UpdateService.new(parent, current_user, update_params).execute(issue)
        end

        milestone.merge_requests.each do |merge_request|
          MergeRequests::UpdateService.new(parent, current_user, update_params).execute(merge_request)
        end

        log_destroy_event_for(milestone)

        milestone.destroy
      end

      if milestone.destroyed?
        milestone_mr_ids.each do |mr_id|
          ::MergeRequests::SyncCodeOwnerApprovalRulesWorker.perform_async(mr_id)
        end
      end

      milestone
    end

    def log_destroy_event_for(milestone)
      return if milestone.group_milestone?

      event_service.destroy_milestone(milestone, current_user)

      Event.for_milestone_id(milestone.id).each do |event|
        event.target_id = nil
        event.save
      end
    end
  end
end
