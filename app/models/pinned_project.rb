# frozen_string_literal: true

class PinnedProject < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :user_id, presence: true
  validates :project_id, presence: true
  # TODO: validate max pinned per user
end
