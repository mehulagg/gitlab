# frozen_string_literal: true

module AuditEvents
  class ImpersonationAuditEventService < ::AuditEventService
    def initialize(author, ip_address, message)
      super(author, author, {
        action: :custom,
        custom_message: message,
        ip_address: ip_address
      })
    end
  end
end
