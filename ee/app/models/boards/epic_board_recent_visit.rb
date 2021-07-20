# frozen_string_literal: true

module Boards
  class EpicBoardRecentVisit < ApplicationRecord
    include BoardRecentVisit

    belongs_to :user, optional: false, inverse_of: :epic_board_recent_visits
    belongs_to :group, optional: false, inverse_of: :epic_board_recent_visits
    belongs_to :epic_board, optional: false, inverse_of: :epic_board_recent_visits

    validates :user, presence: true
    validates :group, presence: true
    validates :epic_board, presence: true

    scope :by_user_parent, -> (user, group) { where(user: user, group: group) }

    def self.board_relation
      :epic_board
    end

    def self.board_parent_relation
      :group
    end
  end
end
