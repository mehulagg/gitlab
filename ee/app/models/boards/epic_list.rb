# frozen_string_literal: true

module Boards
  class EpicList < ApplicationRecord
    # TODO: we can move logic shared with with List model to
    # a module. https://gitlab.com/gitlab-org/gitlab/-/issues/296559
    belongs_to :epic_board, optional: false, inverse_of: :epic_lists
    belongs_to :label, inverse_of: :epic_lists

    enum list_type: { backlog: 0, label: 1, closed: 2 }

    validates :label, :position, presence: true, if: :label?
    validates :label_id, uniqueness: { scope: :epic_board_id }, if: :label?
    validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :label?

    scope :ordered, -> { order(:list_type, :position) }
    scope :movable, -> { where(list_type: list_types.slice(*movable_types).values) }

    def self.movable_types
      [:label]
    end

    def title
      label? ? label.name : list_type.humanize
    end

    def movable?
      label?
    end
  end
end
