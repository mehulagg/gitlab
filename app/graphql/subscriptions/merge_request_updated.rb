# frozen_string_literal: true

module Subscriptions
  class MergeRequestUpdated < Subscriptions::BaseSubscription
    payload_type Types::MergeRequestType

    argument :project_path, GraphQL::ID_TYPE,
             required: true,
             description: 'Project path of the merge request'

    argument :iid, GraphQL::STRING_TYPE,
             required: true,
             description: 'IID of the merge request'

    def authorized?(project_path:, iid:)
      if context.query.subscription_update?
        merge_request = object
      else
        project = Project.find_by_full_path(project_path)
        merge_request = project.merge_requests.find_by_iid(iid)
      end

      merge_request && Ability.allowed?(current_user, :read_merge_request, merge_request)
    end
  end
end
