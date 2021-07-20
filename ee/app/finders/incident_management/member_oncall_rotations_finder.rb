# frozen_string_literal: true

module IncidentManagement
  # A finder used to find all rotations related to a member.
  # For most cases you will want to use `OncallRotationsFinder` instead.
  # For a group member, finds all rotations that user is part of in the group
  # For a project member, find all the rotations that user is part of in the project.
  class MemberOncallRotationsFinder
    def initialize(member)
      @member = member
      @user = member.user
    end

    def execute
      projects = member.source.is_a?(Group) ? member.source.projects : member.source

      for_projects(projects)
    end

    private

    attr_reader :member, :user

    def for_projects(projects)
      user.oncall_rotations.for_project(projects)
    end
  end
end
