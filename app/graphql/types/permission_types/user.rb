# frozen_string_literal: true

module Types
  module PermissionTypes
    class User < BasePermissionType
      graphql_name 'UserPermissions'

      permission_field :create_snippet

      def create_snippet
        Ability.allowed?(current_user, :create_snippet)
      end
    end
  end
end
