# frozen_string_literal: true

class Epic::Board < ApplicationRecord
  belongs_to :group
  has_many :epic_board_labels, class_name: 'Epic::BoardLabel', foreign_key: :epic_board_id

  validates :group, presence: true
end
