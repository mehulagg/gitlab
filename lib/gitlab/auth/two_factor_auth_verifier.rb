# frozen_string_literal: true

module Gitlab
  module Auth
    class TwoFactorAuthVerifier
      attr_reader :current_user, :request

      def initialize(current_user, request)
        @current_user = current_user
        @request = request
      end

      def two_factor_authentication_required?
        return false if provider_exempt?

        Gitlab::CurrentSettings.require_two_factor_authentication? ||
          current_user&.require_two_factor_authentication_from_group?
      end

      def current_user_needs_to_setup_two_factor?
        current_user && !current_user.temp_oauth_email? && !current_user.two_factor_enabled?
      end

      def provider_exempt?
        auth_hash = request.env['omniauth.auth']

        return false unless auth_hash
        return false unless auth_hash.provider.present?

        providers = Gitlab.config.omniauth.allow_bypass_two_factor
        return providers if [true, false].include?(providers)
        return false unless providers.is_a?(Array)

        providers.include?(auth_hash.provider)
      end

      def two_factor_grace_period
        periods = [Gitlab::CurrentSettings.two_factor_grace_period]
        periods << current_user.two_factor_grace_period if current_user&.require_two_factor_authentication_from_group?
        periods.min
      end

      def two_factor_grace_period_expired?
        time = current_user&.otp_grace_period_started_at

        return false unless time

        two_factor_grace_period.hours.since(time) < Time.current
      end
    end
  end
end
