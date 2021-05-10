# frozen_string_literal: true

module Users
  class ShadowBanService < BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(user)
      if user.shadow_ban
        success
      else
        messages = user.errors.full_messages
        error(messages.uniq.join('. '))
      end
    end
  end
end
