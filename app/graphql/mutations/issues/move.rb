# frozen_string_literal: true

module Mutations
  module Issues
    class Move < Base
      graphql_name 'IssueMove'

      argument :target_project_path,
               GraphQL::ID_TYPE,
               required: true,
               description: 'The project to move the issue to.'

      def resolve(project_path:, iid:, target_project_path:)
        issue = authorized_find!(project_path: project_path, iid: iid)
        project = issue.project
        target_project = resolve_project(target_project_path)

        ::Issues::MoveService.new(project, current_user).execute(issue, target_project)

      rescue ::Issues::MoveService::MoveError => ex
        result = ex.message
      ensure
        {
          issue: issue,
          errors: Array.wrap(result)
        }
      end
    end
  end
end
