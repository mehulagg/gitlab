# frozen_string_literal: true

module Users
  class ApproveService < BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(user)
      return error(_('You are not allowed to approve a user')) unless allowed?
      return error(_('The user you are trying to approve is not pending an approval')) unless approval_required?(user)

      if activate_and_confirm(user)
        user.accept_pending_invitations!
        success
      else
        error(user.errors.full_messages.uniq.join('. '))
      end
    end

    private

    attr_reader :current_user

    def allowed?
      can?(current_user, :approve_user)
    end

    def approval_required?(user)
      user.blocked_pending_approval?
    end

    def activate_and_confirm(user)
      user.activate && confirm_user(user)
    end

    def confirm_user(user)
      return true if user.confirmed?

      # This is required to confirm the user even if the validity period of
      # the present confirmation token has expired.
      # See Devise's `confirmation_period_expired?` method for details.
      user.confirmation_sent_at = Time.current
      user.confirm
    end
  end
end
