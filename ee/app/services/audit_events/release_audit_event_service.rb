# frozen_string_literal: true

module AuditEvents
  class ReleaseAuditEventService < ::AuditEventService
    attr_reader :release

    def initialize(author, entity, ip_address, release)
      @release = release

      super(author, entity, {
        custom_message: message,
        ip_address: ip_address,
        target_id: release.id,
        target_type: release.class.name,
        target_details: release.name
      })
    end

    def message
      nil
    end
  end
end
