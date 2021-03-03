# frozen_string_literal: true

module Boards
  class EpicListUserPreference < ApplicationRecord
    belongs_to :user
    belongs_to :epic_list, foreign_key: :epic_list_id, inverse_of: :epic_list_user_preferences

    validates :user, presence: true
    validates :epic_list, presence: true
    validates :user_id, uniqueness: { scope: :epic_list_id, message: "should have only one epic list preference per user" }
  end
end
