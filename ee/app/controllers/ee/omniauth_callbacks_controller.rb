# frozen_string_literal: true

module EE
  module OmniauthCallbacksController
    extend ::Gitlab::Utils::Override

    def kerberos_spnego
      # The internal kerberos_spnego provider is a replacement for
      # omniauth-kerberos. Here we re-use the 'kerberos' provider name to ease
      # the transition. In time (in GitLab 9.0?) we should remove the
      # omniauth-kerberos gem and rename the internal 'kerberos_spnego'
      # provider to plain 'kerberos' and remove this special method.
      oauth['provider'] = 'kerberos'
      handle_omniauth
    end

    private

    override :log_failed_login
    def log_failed_login(author, provider)
      ::AuditEventService.new(
        author,
        nil,
        with: provider
      ).for_failed_login.unauth_security_event
    end
  end
end
