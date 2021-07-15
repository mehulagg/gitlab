# frozen_string_literal: true

module Users
  class UnbanService < BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(user)
      return error(_('You are not allowed to unban a user'), :forbidden) unless allowed?

      if user.activate
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

    def log_event(user)
      Gitlab::AppLogger.info(message: "User unbanned", user: "#{user.username}", email: "#{user.email}", banned_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
    end
  end
end
