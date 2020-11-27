# frozen_string_literal: true

module Boards
  class EpicBoardLabel < ApplicationRecord
    self.table_name = 'boards_epic_board_labels'

    belongs_to :epic_board, class_name: 'Boards::EpicBoard'
    belongs_to :label

    validates :epic_board, presence: true
    validates :label, presence: true
  end
end
