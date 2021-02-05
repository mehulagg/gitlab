# frozen_string_literal: true

module EE
  module Users
    module RejectService
      extend ::Gitlab::Utils::Override

      private

      override :after_reject_hook
      def after_reject_hook(user)
        super

        log_audit_event(user)
      end

      def log_audit_event(user)
        ::AuditEventService.new(
          current_user,
          user,
          action: :custom,
          custom_message: _('Instance access request rejected')
        ).for_user.security_event
      end
    end
  end
end
