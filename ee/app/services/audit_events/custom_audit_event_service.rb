# frozen_string_literal: true

module AuditEvents
  class CustomAuditEventService < ::AuditEventService
    def initialize(author, entity, ip_address, custom_message)
      super(author, entity, {
        action: :custom,
        custom_message: custom_message,
        ip_address: ip_address
      })
    end
  end
end
