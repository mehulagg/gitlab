# frozen_string_literal: true

module EE
  module AuditEvents
    class ReleaseUpdatedAuditEventService < ReleaseAuditEventService
      def message
        "Updated Release #{release.tag}"
      end
    end
  end
end
