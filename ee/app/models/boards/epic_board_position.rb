# frozen_string_literal: true

module Boards
  class EpicBoardPosition < ApplicationRecord
    include RelativePositioning

    belongs_to :epic_board, optional: false, inverse_of: :epic_board_positions
    belongs_to :epic, optional: false

    alias_attribute :parent, :epic_board
    validates :epic, uniqueness: { scope: :epic_board_id }

    scope :order_relative_position, -> do
      reorder('relative_position ASC', 'id DESC')
    end

    def self.relative_positioning_query_base(position)
      where(epic_board_id: position.epic_board_id)
    end

    def self.relative_positioning_parent_column
      :epic_board_id
    end

    def self.last_for_board_id(board_id)
      where(epic_board_id: board_id).order(:relative_position).last
    end
  end
end
