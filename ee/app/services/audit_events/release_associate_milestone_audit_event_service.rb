# frozen_string_literal: true

module AuditEvents
  class ReleaseAssociateMilestoneAuditEventService < ReleaseAuditEventService
    def message
      milestones = @release.milestone_titles
      milestones = "[none]" if milestones.blank?

      "Milestones associated with release changed to #{milestones}"
    end
  end
end
