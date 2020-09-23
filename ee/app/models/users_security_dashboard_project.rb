# frozen_string_literal: true

class UsersSecurityDashboardProject < ApplicationRecord
  SECURITY_DASHBOARD_PROJECTS_LIMIT = 1000

  belongs_to :project
  belongs_to :user

  validates :user, presence: true
  validates :project, presence: true
  validates :project_id, uniqueness: { scope: [:user_id] }
  validate :per_user_projects_limit

  def self.delete_by_project_id(project_id)
    where(project_id: project_id).delete_all
  end

  private

  def per_user_projects_limit
    if self.class.where(user: user).count >= SECURITY_DASHBOARD_PROJECTS_LIMIT
      errors.add(:project, _('limit of %{project_limit} reached') % { project_limit: SECURITY_DASHBOARD_PROJECTS_LIMIT })
    end
  end
end
