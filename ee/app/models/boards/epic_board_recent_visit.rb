# frozen_string_literal: true

module Boards
  class EpicBoardRecentVisit < ApplicationRecord
    belongs_to :group, optional: false, inverse_of: :epic_board_recent_visits
    belongs_to :epic_board, optional: false, inverse_of: :epic_board_recent_visits
    belongs_to :user, optional: false, inverse_of: :epic_board_recent_visits
  end
end
