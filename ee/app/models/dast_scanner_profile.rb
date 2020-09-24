# frozen_string_literal: true

class DastScannerProfile < ApplicationRecord
  belongs_to :project

  validates :project_id, presence: true
  validates :name, length: { maximum: 255 }, uniqueness: { scope: :project_id }

  scope :project_id_in, -> (project_ids) { where(project_id: project_ids) }

  enum scan_type: {
    PASSIVE: 1,
    ACTIVE: 2
  }
end
