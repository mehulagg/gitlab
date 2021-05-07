# frozen_string_literal: true

module EE
  module Users
    module ApproveService
      extend ::Gitlab::Utils::Override

      private

      override :after_approve_hook
      def after_approve_hook(user)
        super

        log_audit_event(user)
      end

      def log_audit_event(user)
        ::AuditEventService.new(
          current_user,
          user,
          action: :custom,
          custom_message: _('Instance access request approved')
        ).for_user.security_event
      end
    end
  end
end
