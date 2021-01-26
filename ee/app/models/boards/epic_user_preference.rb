# frozen_string_literal: true

module Boards
  class EpicUserPreference < ApplicationRecord
    self.table_name = 'boards_epic_user_preferences'

    belongs_to :user, inverse_of: :boards_epic_user_preferences
    belongs_to :board, inverse_of: :boards_epic_user_preferences
    belongs_to :epic, inverse_of: :boards_epic_user_preferences

    validates :user, uniqueness: { scope: [:board_id, :epic_id] }

    scope :for_boards_and_epics, -> (board_ids, epic_ids) do
      where(board_id: board_ids, epic_id: epic_ids)
    end
  end
end
