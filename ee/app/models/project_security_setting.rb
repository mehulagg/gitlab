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

  def auto_fix_enabled
    auto_fix = [ :auto_fix_container_scanning, :auto_fix_dast, :auto_fix_dependency_scanning, :auto_fix_sast ]
    auto_fix.filter { |setting| !!setting }
  end
end
