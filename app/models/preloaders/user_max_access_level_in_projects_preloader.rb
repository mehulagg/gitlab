# frozen_string_literal: true

module Preloaders
  # This class preloads the max access level for the user within the given projects and
  # stores the values in requests store via the ProjectTeam class.
  class UserMaxAccessLevelInProjectsPreloader
    def initialize(projects, user)
      @projects = projects
      @user = user
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def execute
      access_levels = @user
        .project_authorizations
        .where(project_id: @projects)
        .group(:project_id)
        .maximum(:access_level)

      access_levels.each do |project_id, access_level|
        project = @projects.find { |p| p.id == project_id }

        ProjectTeam.new(project).write_member_access_for_user_id(@user.id, access_level)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
