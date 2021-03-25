# frozen_string_literal: true

module Mutations
  module Assignable
    extend ActiveSupport::Concern

    included do
      argument :assignee_usernames,
               [GraphQL::STRING_TYPE],
               required: true,
               description: 'The usernames to assign to the resource. Replaces existing assignees by default.'

      argument :operation_mode,
               Types::MutationOperationModeEnum,
               required: false,
               default_value: Types::MutationOperationModeEnum.default_mode,
               description: 'The operation to perform. Defaults to REPLACE.'
    end

    def resolve(project_path:, iid:, assignee_usernames:, operation_mode:)
      resource = authorized_find!(project_path: project_path, iid: iid)

      update_service_class.new(
        resource.project,
        current_user,
        assignee_ids: assignee_ids(resource, assignee_usernames, operation_mode)
      ).execute(resource)

      {
        resource.class.name.underscore.to_sym => resource,
        errors: errors_on_object(resource)
      }
    end

    private

    def assignee_ids(resource, usernames, mode)
      old = current_assignee_ids(resource, mode)
      new = UsersFinder.new(current_user, username: usernames).execute.map(&:id)

      Types::MutationOperationModeEnum.transform_list(mode, old, new)
    end

    def current_assignee_ids(resource, mode)
      return unless ::Types::MutationOperationModeEnum.transform_modes.include?(mode)

      resource.assignees.map(&:id)
    end
  end
end
