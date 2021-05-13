# frozen_string_literal: true

class BoardLabel < NamespaceShard
  belongs_to :board
  belongs_to :label

  validates :board, presence: true
  validates :label, presence: true
end
