# frozen_string_literal: true

module Boards
  class EpicBoard < ApplicationRecord
    belongs_to :group, optional: false, inverse_of: :epic_boards
    has_many :epic_board_labels, foreign_key: :epic_board_id, inverse_of: :epic_board
    has_many :epic_board_positions, foreign_key: :epic_board_id, inverse_of: :epic_board
    has_many :epic_lists, -> { ordered }, foreign_key: :epic_board_id, inverse_of: :epic_board

    validates :name, length: { maximum: 255 }

    scope :order_by_name_asc, -> { order(arel_table[:name].lower.asc).order(id: :asc) }

    def lists
      epic_lists
    end

    def resource_parent
      group
    end

    def group_board?
      true
    end

    def scoped?
      false
    end

    def milestone_id
      nil
    end

    def milestone
      nil
    end

    def iteration_id
      nil
    end

    def iteration
      nil
    end

    def assignee_id
      nil
    end

    def assignee
      nil
    end

    def label_ids
      []
    end

    def labels
      []
    end

    def weight
      nil
    end
  end
end
