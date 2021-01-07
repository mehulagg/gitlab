# frozen_string_literal: true

module Resolvers
  module Terraform
    class StatesResolver < BaseResolver
      type Types::Terraform::StateType.connection_type, null: true

      alias_method :project, :object

      when_single do
        argument :name, GraphQL::STRING_TYPE,
            required: true,
            description: 'Name of the Terraform state.'
      end

      def resolve(**args)
        ::Terraform::StatesFinder
          .new(project, current_user, params: args)
          .execute
      end

      private

      def can_read_terraform_states?
        current_user.can?(:read_terraform_state, project)
      end
    end
  end
end
