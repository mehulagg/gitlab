# frozen_string_literal: true

module Users
  class UnbanService < BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(user)
      if user.activate
        log_event(user)
        unhide_issues(user)

        success
      else
        messages = user.errors.full_messages
        error(messages.uniq.join('. '))
      end
    end

    private

    def unhide_issues(user)
      user.issues.update_all(hidden: false)
    end

    def log_event(user)
      Gitlab::AppLogger.info(message: "User unbanned", user: "#{user.username}", email: "#{user.email}", unbanned_by: "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
    end
  end
end
