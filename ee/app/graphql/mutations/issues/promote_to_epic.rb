# frozen_string_literal: true

module Mutations
  module Issues
    class PromoteToEpic < Base
      graphql_name 'PromoteToEpic'

      argument :epic_group_id, ::Types::GlobalIDType[::Group],
               required: false,
               description: 'The group the promoted epic belongs to'

      field :epic,
            Types::EpicType,
            null: true,
            description: "The epic after issue promotion"

      def resolve(project_path:, iid:, epic_group_id:)
        errors = []
        issue = authorized_find!(project_path: project_path, iid: iid)
        project = issue.project
        group = epic_group(epic_group_id)

        begin
          epic = ::Epics::IssuePromoteService.new(project, current_user).execute(issue, group)
        rescue => error
          errors << error.message
        end

        errors << issue&.errors&.full_messages
        errors << epic&.errors&.full_messages

        {
          issue: issue,
          epic: epic,
          errors: errors.compact.flatten
        }
      end

      private

      def epic_group(group_id)
        return unless group_id

        GlobalID::Locator.locate(group_id)
      end
    end
  end
end
