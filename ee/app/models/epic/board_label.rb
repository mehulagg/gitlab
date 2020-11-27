# frozen_string_literal: true

class Epic::BoardLabel < ApplicationRecord
  belongs_to :epic_board, class_name: 'Epic::Board'
  belongs_to :label

  validates :epic_board, presence: true
  validates :label, presence: true
end
