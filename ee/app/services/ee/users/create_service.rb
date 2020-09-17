# frozen_string_literal: true

module EE
  module Users
    module CreateService
      extend ::Gitlab::Utils::Override

      override :after_create_hook
      def after_create_hook(user, reset_token)
        super

        log_audit_event(user) if audit_required?
      end

      private

      def log_audit_event(user)
        ::AuditEventService.new(
          current_user,
          user,
          action: :create
        ).for_user.security_event
      end

      def audit_required?
        current_user.present?
      end
    end
  end
end
