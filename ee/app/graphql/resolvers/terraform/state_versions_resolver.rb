# frozen_string_literal: true

module Resolvers
  module Terraform
    class StateVersionsResolver < BaseResolver
      type Types::Terraform::StateVersionType, null: true

      alias_method :terraform_state, :object

      delegate :project, to: :terraform_state

      def resolve(**args)
        return ::Terraform::StateVersion.none unless can_view_state_history?

        terraform_state.versions.ordered_by_version_desc
      end

      private

      def can_view_state_history?
        project.feature_available?(:terraform_state_history) && current_user.can?(:read_terraform_state, project)
      end
    end
  end
end
