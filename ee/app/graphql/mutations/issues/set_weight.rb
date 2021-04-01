# frozen_string_literal: true

module Mutations
  module Issues
    class SetWeight < ::Mutations::Issues::Base
      graphql_name 'IssueSetWeight'

      argument :weight,
               GraphQL::INT_TYPE,
               required: true,
               description: 'The desired weight for the issue.'

      def resolve(project_path:, iid:, weight:)
        issue = authorized_find!(project_path: project_path, iid: iid)
        project = issue.project

        # TODO: Switch constructor hierarchy to use named arguments, in order to avoid needing to pass spam_params: nil
        ::Issues::UpdateService.new(project, current_user, { weight: weight }, spam_params: nil)
          .execute(issue)

        {
          issue: issue,
          errors: issue.errors.full_messages
        }
      end
    end
  end
end
