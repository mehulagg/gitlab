# frozen_string_literal: true

module Users
  class BannedUserService < BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(user, action)
      return error(_("You are not allowed to %{action} a user" % { action: action.to_s }), :forbidden) unless allowed?

      case action
      when :ban
        update = user.ban
      when :unban
        update = user.activate
      end

      if update
        log_event(user, action)
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

    def log_event(user, action)
      Gitlab::AppLogger.info(message: "User #{action}", user: "#{user.username}", email: "#{user.email}", "#{action}_by": "#{current_user.username}", ip_address: "#{current_user.current_sign_in_ip}")
    end
  end
end
