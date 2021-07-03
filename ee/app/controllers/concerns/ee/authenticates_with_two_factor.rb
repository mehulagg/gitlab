# frozen_string_literal: true

module EE
  module AuthenticatesWithTwoFactor
    extend ::Gitlab::Utils::Override

    override :log_failed_two_factor
    def log_failed_two_factor(user, method)
      ::AuditEventService.new(
        user,
        user,
        with: method
      ).for_failed_login.unauth_security_event
    end
  end
end
