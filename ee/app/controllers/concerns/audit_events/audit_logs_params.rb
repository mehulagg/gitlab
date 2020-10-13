# frozen_string_literal: true

module AuditEvents
  module AuditLogsParams
    def audit_logs_params
      params.permit(:entity_type, :entity_id, :created_before, :created_after, :sort, :author_id)
    end
  end
end
