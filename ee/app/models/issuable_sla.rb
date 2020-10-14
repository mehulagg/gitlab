# frozen_string_literal: true

class IssuableSla < ApplicationRecord
  belongs_to :issue, optional: false
  validates :due_at, presence: true
end
