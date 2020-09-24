# frozen_string_literal: true

module Subscriptions
  class IssueUpdated < Subscriptions::BaseSubscription
    payload_type Types::IssueType

    argument :project_path, GraphQL::ID_TYPE,
             required: true,
             description: 'Project path of the issue'

    argument :iid, GraphQL::STRING_TYPE,
             required: true,
             description: 'IID of the issue'

    def authorized?(project_path:, iid:)
      if context.query.subscription_update?
        issue = object
      else
        project = Project.find_by_full_path(project_path)
        issue = project.issues.find_by_iid(iid)
      end

      issue && Ability.allowed?(current_user, :read_issue, issue)
    end
  end
end
