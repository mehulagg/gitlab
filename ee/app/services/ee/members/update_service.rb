# frozen_string_literal: true

module EE
  module Members
    module UpdateService
      extend ActiveSupport::Concern

      def after_execute(action:, old_access_level:, old_expiry:, member:)
        super

        log_audit_event(action: action, old_access_level: old_access_level, old_expiry: old_expiry, member: member)
      end

      private

      def log_audit_event(action:, old_access_level:, old_expiry:, member:)
        ::AuditEventService.new(
          current_user,
          member.source,
          action: action,
          old_access_level: old_access_level,
          old_expiry: old_expiry
        ).for_member(member).security_event
      end
    end
  end
end
