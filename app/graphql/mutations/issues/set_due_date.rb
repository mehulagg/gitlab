# frozen_string_literal: true

module Mutations
  module Issues
    class SetDueDate < Base
      graphql_name 'IssueSetDueDate'

      argument :due_date,
               Types::TimeType,
               required: false,
               description: 'The desired due date for the issue, ' \
               'due date will be removed if absent or set to null'

      def resolve(project_path:, iid:, due_date: nil)
        issue = authorized_find!(project_path: project_path, iid: iid)
        project = issue.project

        ::Issues::UpdateService.new(project, current_user, due_date: due_date)
          .execute(issue)

        {
          issue: issue,
          errors: errors_on_object(issue)
        }
      end
    end
  end
end
