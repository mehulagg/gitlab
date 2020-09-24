# frozen_string_literal: true

module EE
  module Users
    module BlockService
      extend ::Gitlab::Utils::Override

      override :after_block_hook
      def after_block_hook(user)
        super

        log_audit_event(user)
      end

      private

      def log_audit_event(user)
        ::AuditEventService.new(
          current_user,
          user,
          action: :custom,
          custom_message: 'Blocked user'
        ).for_user.security_event
      end
    end
  end
end
