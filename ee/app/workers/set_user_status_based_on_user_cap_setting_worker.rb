# frozen_string_literal: true

class SetUserStatusBasedOnUserCapSettingWorker
  include ApplicationWorker

  feature_category :users

  idempotent!

  def perform(user_id)
    user = User.find_by_id(user_id)

    return unless user.blocked_pending_approval?
    return if user_cap_max.nil?
    return if current_billable_users_count >= user_cap_max

    if user.activate
      # Resends confirmation email if the user isn't confirmed yet.
      # Please see Devise's implementation of `resend_confirmation_instructions` for detail.
      user.resend_confirmation_instructions
      user.accept_pending_invitations! if user.active_for_authentication?
      DeviseMailer.user_admin_approval(user).deliver_later
    else
      logger.error(message: "Approval of user id=#{user_id} failed")
    end
  end

  private

  def user_cap_max
    ::Gitlab::CurrentSettings.new_user_signups_cap
  end

  def current_billable_users_count
    User.billable.count
  end
end
