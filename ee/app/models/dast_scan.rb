# frozen_string_literal: true

class DastScan < ApplicationRecord
  belongs_to :project
  belongs_to :dast_site_profile
  belongs_to :dast_scanner_profile

  validates :description, length: { maximum: 255 }
  validates :name, length: { maximum: 255 }, uniqueness: { scope: :project_id }
  validates :project_id, :dast_site_profile_id, :dast_scanner_profile_id, presence: true

  validate :project_ids_match

  private

  def project_ids_match
    unless project_id == dast_site_profile&.project_id && project_id == dast_scanner_profile&.project_id
      errors.add(:project_id, 'does not match dast_site_profile.project and dast_scanner_profile.project')
    end
  end
end
