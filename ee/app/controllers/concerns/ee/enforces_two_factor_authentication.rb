# frozen_string_literal: true

module EE
  module EnforcesTwoFactorAuthentication
    extend ::Gitlab::Utils::Override

    override :current_user_requires_two_factor?
    def current_user_requires_two_factor?
      super && !active_smartcard_session?
    end

    private

    def active_smartcard_session?
      return false unless ::Gitlab::Auth::Smartcard.enabled?

      return false unless current_user.smartcard_identities.any?

      ::Gitlab::Auth::Smartcard::Session.new.active?(current_user)
    end
  end
end
