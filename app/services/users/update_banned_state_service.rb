# frozen_string_literal: true
module Users
  class UpdateBannedStateService < UpdateService
    def initialize(current_user)
      @current_user = current_user
    end

    def ban_user(user)
      return error(_('You are not allowed to ban a user'), :forbidden) unless allowed?

      if user.ban
        log_event(user, "ban")
        hide_issues(user)

        success
      else
        messages = user.errors.full_messages
        error(messages.uniq.join('. '))
      end
    end

    def unban_user(user)
      return error(_('You are not allowed to unban a user'), :forbidden) unless allowed?

      if user.activate
        log_event(user, "unban")
        unhide_issues(user)

        success
      else
        messages = user.errors.full_messages
        error(messages.uniq.join('. '))
      end
    end

    private

    def allowed?
      can?(current_user, :admin_all_resources)
    end

    def hide_issues(user)
      banned_user = BannedUser.new(user: user)

      banned_user.update_attribute(:ban_state, "ban_in_progress")

      Users::UpdateContributionHiddenWorker.perform_async(user.id, "ban")
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def unhide_issues(user)
      banned_user = BannedUser.find_by(user_id: user.id)

      banned_user.update_attribute(:ban_state, "unban_in_progress")

      Users::UpdateContributionHiddenWorker.perform_async(user.id, "unban")
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def log_event(user, action)
      case action
      when "ban"
        Gitlab::AppLogger.info(message: "User banned", user: "#{user.username}", email: "#{user.email}", banned_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
      when "unban"
        Gitlab::AppLogger.info(message: "User unbanned", user: "#{user.username}", email: "#{user.email}", unbanned_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
      end
    end
  end
end
