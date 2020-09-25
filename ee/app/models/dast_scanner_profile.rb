# frozen_string_literal: true

class DastScannerProfile < ApplicationRecord
  belongs_to :project

  validates :project_id, presence: true
  validates :name, length: { maximum: 255 }, uniqueness: { scope: :project_id }

  enum scan_type: {
    PASSIVE: 1,
    ACTIVE: 2
  }
end
