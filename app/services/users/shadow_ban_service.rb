# frozen_string_literal: true

module Users
  class ShadowBanService < BaseService
    def initialize(current_user)
      @current_user = current_user
    end

    def execute(user)
      return error('An internal user cannot be shadow_banned', 403) if user.internal?

      if user.block
        success
      else
        messages = user.errors.full_messages
        error(messages.uniq.join('. '))
      end
    end
  end
end
