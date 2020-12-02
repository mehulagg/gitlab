# frozen_string_literal: true
#
class ProjectSecuritySetting < ApplicationRecord
  self.primary_key = :project_id

  # Note: Even if we store settings for all types of security scanning
  # Currently, Auto-fix feature is available only for container_scanning and
  # dependency_scanning features.
  AVAILABLE_AUTO_FIX_TYPES = [:dependency_scanning, :container_scanning].freeze

  belongs_to :project, inverse_of: :security_setting

  def self.safe_find_or_create_for(project)
    project.security_setting || project.create_security_setting
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def auto_fix_enabled?
    auto_fix_enabled_types.any?
  end

  def auto_fix_enabled_types
    AVAILABLE_AUTO_FIX_TYPES.filter_map do |type|
      type if public_send("auto_fix_#{type}") # rubocop:disable GitlabSecurity/PublicSend
    end
  end
end
