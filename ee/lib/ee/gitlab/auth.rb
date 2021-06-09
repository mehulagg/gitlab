# frozen_string_literal: true

module EE
  module Gitlab
    module Auth
      extend ::Gitlab::Utils::Override

      override :find_with_user_password
      def find_with_user_password(login, password, increment_failed_attempts: false)
        if Devise.omniauth_providers.include?(:kerberos)
          kerberos_user = ::Gitlab::Kerberos::Authentication.login(login, password)
          return kerberos_user if kerberos_user
        end

        super
      end
    end
  end
end
