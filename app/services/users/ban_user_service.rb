# frozen_string_literal: true

module Users
  class BanUserService < BannedUserBaseService
    ACTION = :ban

    def execute(user)
      return service_error(ACTION) unless allowed?

      if user.ban
        log_event(user, action)
        success
      else
        messages = user.errors.full_messages
        service_error(messages.uniq.join('. '))
      end
    end
  end
end
