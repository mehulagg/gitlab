# frozen_string_literal: true

module AuditEvents
  class ReleaseUpdatedAuditEventService < ReleaseAuditEventService
    def message
      "Updated Release #{release.tag}"
    end
  end
end
