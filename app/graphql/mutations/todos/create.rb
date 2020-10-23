# frozen_string_literal: true

module Mutations
  module Todos
    class Create < ::Mutations::Todos::Base
      graphql_name 'TodoMarkDone'

      argument :target_id,
               Types::GlobalIDType[Issuable],
               required: true,
               description: 'The global id of todo parent'

      field :todo, Types::TodoType,
            null: true,
            description: 'The todo created'

      def resolve(id:)
        target = find_target(id)

        todo = TodoService.new.mark_todo(target, current_user)

        {
          todo: todo,
          errors: errors_on_object(todo)
        }
      end

      private

      def find_target!(id)
        id = ::Types::GlobalIDType[::Issuable].coerce_isolated_input(id)

        # Raise error here depending of user cannot create todo for target

        GitlabSchema.find_by_gid(id)
      end
    end
  end
end
