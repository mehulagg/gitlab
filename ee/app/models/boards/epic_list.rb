# frozen_string_literal: true

module Boards
  class EpicList < ApplicationRecord
    include ::Boards::Listable

    belongs_to :epic_board, optional: false, inverse_of: :epic_lists
    belongs_to :label, inverse_of: :epic_lists

    validates :label_id, uniqueness: { scope: :epic_board_id }, if: :label?

    enum list_type: { backlog: 0, label: 1, closed: 2 }
  end
end
