# frozen_string_literal: true

module Users
  class BanService < BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(user)
      return error(_('You are not allowed to ban a user'), :forbidden) unless allowed?

      if user.ban
        update_ban_state(user)
        hide_contributions(user)
        log_event(user)
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

    def update_ban_state(user)
      banned_user = user.banned_user

      if !banned_user
        Users::BannedUser.new(user: user, ban_state: 2).save
      else
        banned_user.update_attribute(:ban_state, 2)
      end
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def hide_contributions(user)
      Users::HideContributionsWorker.perform_async(user.id)

      unless Issue.where(author_id: user.id).where(hidden: false).any?
        user.banned_user.update_attribute(:ban_state, 3)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def log_event(user)
      Gitlab::AppLogger.info(message: "User banned", user: "#{user.username}", email: "#{user.email}", banned_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
    end
  end
end
