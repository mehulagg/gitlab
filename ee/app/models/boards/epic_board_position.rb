# frozen_string_literal: true

module Boards
  class EpicBoardPosition < ApplicationRecord
    include RelativePositioning
    include BulkInsertSafe

    belongs_to :epic_board, optional: false, inverse_of: :epic_board_positions
    belongs_to :epic, optional: false

    alias_attribute :parent, :epic_board
    validates :epic, uniqueness: { scope: :epic_board_id }

    scope :order_relative_position, -> do
      reorder('relative_position ASC', 'id DESC')
    end

    class << self
      def relative_positioning_query_base(position)
        where(epic_board_id: position.epic_board_id)
      end

      def relative_positioning_parent_column
        :epic_board_id
      end

      def last_for_board_id(board_id)
        where(epic_board_id: board_id).order(::Gitlab::Database.nulls_first_order('boards_epic_board_positions.relative_position', 'DESC')).first
      end

      def bulk_upsert(positions)
        bulk_upsert!(positions, unique_by: %i[epic_board_id epic_id])
      end
    end
  end
end
