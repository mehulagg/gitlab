# frozen_string_literal: true

module Types
  module PermissionTypes
    class Requirement < BasePermissionType
      graphql_name 'RequirementPermissions'
      description 'Check permissions for the current user on a requirement'

      abilities :read_requirement, :update_requirement, :destroy_requirement,
                :admin_requirement, :create_requirement
    end
  end
end
