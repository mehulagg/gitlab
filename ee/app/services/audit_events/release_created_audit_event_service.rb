# frozen_string_literal: true

module AuditEvents
  class ReleaseCreatedAuditEventService < ReleaseAuditEventService
    def message
      simple_message = "Created Release #{release.tag}"
      milestone_count = release.milestones.count

      if milestone_count > 0
        "#{simple_message} with #{'Milestone'.pluralize(milestone_count)} #{release.milestone_titles}"
      else
        simple_message
      end
    end
  end
end
