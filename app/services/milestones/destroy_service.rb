# frozen_string_literal: true

module Milestones
  class DestroyService < Milestones::BaseService
    def execute(milestone)
      Milestone.transaction do
        Issuable::BulkUpdateService.new(parent, current_user, update_params(milestone.issues)).execute('issue')
        Issuable::BulkUpdateService.new(parent, current_user, update_params(milestone.merge_requests)).execute('merge_request')

        log_destroy_event_for(milestone)

        milestone.destroy
      end
    end

    def log_destroy_event_for(milestone)
      return if milestone.group_milestone?

      event_service.destroy_milestone(milestone, current_user)

      Event.for_milestone_id(milestone.id).each do |event|
        event.target_id = nil
        event.save
      end
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def update_params(issuables)
      {
        milestone: nil,
        skip_milestone_email: true,
        issuable_ids: issuables.pluck(:id)
      }
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
