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
end
