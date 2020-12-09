# frozen_string_literal: true

module EE
  module RegistrationsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      before_action :ensure_can_remove_self, only: [:destroy]
    end

    private

    override :set_blocked_pending_approval?
    def set_blocked_pending_approval?
      super || ::Gitlab::CurrentSettings.should_apply_user_signup_cap?
    end

    def ensure_can_remove_self?
      current_user&.can_remove_self?
    end
  end
end
