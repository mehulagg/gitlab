# frozen_string_literal: true

class BoardUserPreference < ApplicationRecord
  belongs_to :user, inverse_of: :board_preferences
  belongs_to :board, inverse_of: :user_preferences

  validates :user, presence: true
  validates :board, presence: true
  validates :user_id, uniqueness: { scope: :board_id, message: "should have only one board preference per user" }
end
