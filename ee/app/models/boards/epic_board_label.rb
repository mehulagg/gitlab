# frozen_string_literal: true

module Boards
  class EpicBoardLabel < ApplicationRecord
    belongs_to :epic_board, optional: false, inverse_of: :epic_board_labels
    belongs_to :label, optional: false, inverse_of: :epic_board_labels
  end
end
