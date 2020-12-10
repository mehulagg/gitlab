# frozen_string_literal: true

module Boards
  class EpicList < ApplicationRecord
    belongs_to :epic_board, optional: false, inverse_of: :epic_lists
    belongs_to :label, optional: false, inverse_of: :epic_lists

    enum list_type: { backlog: 0, label: 1, closed: 2 }

    validates :position, presence: true

    scope :without_types, ->(list_types) { where.not(list_type: list_types) }
  end
end
