# frozen_string_literal: true

class DastSiteProfile < ApplicationRecord
  belongs_to :project
  belongs_to :dast_site

  has_many :secret_variables, class_name: 'Dast::SiteProfileSecretVariable'

  validates :name, length: { maximum: 255 }, uniqueness: { scope: :project_id }, presence: true
  validates :project_id, :dast_site_id, presence: true
  validate :dast_site_project_id_fk

  scope :with_dast_site_and_validation, -> { includes(dast_site: :dast_site_validation) }
  scope :with_name, -> (name) { where(name: name) }

  after_destroy :cleanup_dast_site

  delegate :dast_site_validation, to: :dast_site, allow_nil: true

  def status
    return DastSiteValidation::NONE_STATE unless dast_site_validation

    dast_site_validation.state
  end

  def referenced_in_security_policies
    return [] unless project.security_orchestration_policy_configuration.present?

    project.security_orchestration_policy_configuration.active_policy_names_with_dast_site_profile(name)
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
