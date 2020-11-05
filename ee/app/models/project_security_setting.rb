# frozen_string_literal: true
#
class ProjectSecuritySetting < ApplicationRecord
  self.primary_key = :project_id

  belongs_to :project, inverse_of: :security_setting

  def self.safe_find_or_create_for(project)
    project.security_setting || project.create_security_setting
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  # Note: Even if we store settings for all types of security scanning
  # Currently, Auto-fix feature is available only for container_scanning and
  # dependency_scanning features.
  def auto_fix_enabled?
    [ auto_fix_container_scanning, auto_fix_dependency_scanning ].any?
  end
end
