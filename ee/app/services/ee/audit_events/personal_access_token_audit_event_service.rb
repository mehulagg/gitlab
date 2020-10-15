# frozen_string_literal: true

module EE
  module AuditEvents
    class PersonalAccessTokenAuditEventService < ::AuditEventService
      def initialize(author, ip_address, message)
        super(author, author, {
          action: :custom,
          custom_message: message,
          ip_address: ip_address
        })
      end
    end
  end
end
