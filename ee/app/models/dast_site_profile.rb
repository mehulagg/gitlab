# frozen_string_literal: true

class DastSiteProfile < ApplicationRecord
  belongs_to :project
  belongs_to :dast_site

  validates :name, length: { maximum: 255 }, uniqueness: { scope: :project_id }
  validates :project_id, :dast_site_id, presence: true
  validate :dast_site_project_id_fk

  scope :with_dast_site_and_validation, -> { includes(dast_site: :dast_site_validation) }

  after_destroy :cleanup_dast_site

  delegate :dast_site_validation, to: :dast_site, allow_nil: true

  def status
    return DastSiteValidation::INITIAL_STATE unless dast_site_validation

    dast_site_validation.state
  end

  private

  def cleanup_dast_site
    dast_site.destroy if dast_site.dast_site_profiles.empty?
  end

  def dast_site_project_id_fk
    unless project_id == dast_site&.project_id
      errors.add(:project_id, 'does not match dast_site.project')
    end
  end
end
