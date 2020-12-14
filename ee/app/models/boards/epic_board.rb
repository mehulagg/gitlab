# frozen_string_literal: true

module Boards
  class EpicBoard < ApplicationRecord
    belongs_to :group, optional: false, inverse_of: :epic_boards
    has_many :epic_board_labels, foreign_key: :epic_board_id, inverse_of: :epic_board
    has_many :epic_board_positions, foreign_key: :epic_board_id, inverse_of: :epic_board

    validates :name, length: { maximum: 255 }

    scope :order_by_name_asc, -> { order(arel_table[:name].lower.asc).order(id: :asc) }
  end
end
