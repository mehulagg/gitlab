# frozen_string_literal: true

module Projects::ProjectMembersHelper
  def can_manage_project_members?
    can?(current_user, :admin_project_member, @project)
  end
end
