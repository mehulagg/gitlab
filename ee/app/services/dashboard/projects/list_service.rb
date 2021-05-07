# frozen_string_literal: true

module Dashboard
  module Projects
    class ListService
      PRESELECT_PROJECTS_LIMIT = 150

      def initialize(user, feature:)
        @user = user
        @feature = feature
      end

      def execute(project_ids, include_unavailable: false)
        return Project.none unless License.feature_available?(feature)

        project_ids = available_project_ids(project_ids) unless include_unavailable
        find_projects(project_ids)
      end

      private

      attr_reader :user, :feature

      # see https://gitlab.com/gitlab-org/gitlab/-/merge_requests/39847
      def available_project_ids(project_ids)
        projects = Project.with_namespace.id_in(project_ids.first(PRESELECT_PROJECTS_LIMIT))
        projects.select { |project| project.feature_available?(feature) }.map(&:id)
      end

      def find_projects(project_ids)
        ProjectsFinder.new(
          current_user: user,
          project_ids_relation: project_ids,
          params: projects_finder_params
        ).execute
      end

      def projects_finder_params
        return {} if user.can?(:read_all_resources)

        {
          min_access_level: ProjectMember::DEVELOPER
        }
      end
    end
  end
end
