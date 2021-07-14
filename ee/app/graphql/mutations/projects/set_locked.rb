# frozen_string_literal: true

module Mutations
  module Projects
    class SetLocked < BaseMutation
      include FindsProject

      graphql_name 'ProjectSetLocked'

      authorize :push_code

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: "The project the merge request to mutate is in."

      argument :file_path, GraphQL::STRING_TYPE,
               required: true,
               description: "The IID of the merge request to mutate."

      argument :locked,
               GraphQL::BOOLEAN_TYPE,
               required: true,
               description: <<~DESC
                 Whether or not to lock the merge request.
               DESC

      field :project, Types::ProjectType, null: true,
        description: 'Project the CI/CD settings belong to.'

      def resolve(project_path:, file_path:, locked:)
        project = authorized_find!(project_path)

        path_lock = project.path_locks.find_by(path: file_path) # rubocop: disable CodeReuse/ActiveRecord

        need_to_lock = !path_lock && locked
        need_to_unlock = path_lock && !locked

        if need_to_unlock
          PathLocks::UnlockService.new(project, current_user).execute(path_lock)
        end

        if need_to_lock
          PathLocks::LockService.new(project, current_user).execute(file_path)
        end

        {
          project: project,
          errors: errors_on_object(project)
        }
      end
    end
  end
end
