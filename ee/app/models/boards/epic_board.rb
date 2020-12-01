# frozen_string_literal: true

module Boards
  class EpicBoard < ApplicationRecord
    self.table_name = 'boards_epic_boards'

    belongs_to :group
    has_many :epic_board_labels, class_name: 'Boards::EpicBoardLabel', foreign_key: :epic_board_id

    validates :group, presence: true

    scope :order_by_name_asc, -> { order(arel_table[:name].lower.asc).order(id: :asc) }
  end
end
