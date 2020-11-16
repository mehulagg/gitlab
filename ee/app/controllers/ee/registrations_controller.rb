# frozen_string_literal: true

module EE
  module RegistrationsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    private

    override :user_created_message
    def user_created_message(confirmed: false)
      experiments = "experiment_growth_recaptcha?#{show_recaptcha_sign_up?}"

      super(confirmed: confirmed) + ", experiments:#{experiments}"
    end

    override :set_user_state
    def set_user_state
      return unless apply_user_signup_cap?

      resource.state = ::RegistrationsController::BLOCKED_PENDING_APPROVAL_STATE
    end

    def apply_user_signup_cap?
      return true if ::Gitlab::CurrentSettings.require_admin_approval_after_user_signup

      ::Feature.enabled?(:admin_new_user_signups_cap) &&
        ::Gitlab::CurrentSettings.new_user_signups_cap
    end
  end
end
