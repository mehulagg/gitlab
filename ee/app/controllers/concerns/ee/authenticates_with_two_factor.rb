# frozen_string_literal: true

module EE
  module AuthenticatesWithTwoFactor
    extend ::Gitlab::Utils::Override

    override :log_failed_two_factor
    def log_failed_two_factor(user, method, ip_address)
      ::AuditEventService.new(
        user,
        user,
        ip_address: ip_address,
        with: method
      ).for_failed_login.unauth_security_event
    end
  end
end
