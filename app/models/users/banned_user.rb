# frozen_string_literal: true

class BannedUser < ApplicationRecord
  belongs_to :user

  enum ban_state: {
    is_not_banned: 0,
    unban_in_progress: 1,
    ban_in_progress: 2,
    is_banned: 3
  }
end
