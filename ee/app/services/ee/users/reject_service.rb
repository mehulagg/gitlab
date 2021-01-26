# frozen_string_literal: true

module EE
  module Users
    module RejectService
      extend ::Gitlab::Utils::Override

      override :after_reject_hook
      def after_reject_hook(user)
        super

        log_audit_event(user)
      end

      private

      def log_audit_event(user)
        ::AuditEventService.new(
          current_user,
          user,
          action: :custom,
          custom_message: 'Instance request rejected'
        ).for_user.security_event
      end
    end
  end
end
