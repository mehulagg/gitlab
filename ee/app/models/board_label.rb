class BoardLabel < ApplicationRecord
  belongs_to :board
  belongs_to :label

  validates :board, presence: true
  validates :label, presence: true
end
