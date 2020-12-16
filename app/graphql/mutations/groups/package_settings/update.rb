# frozen_string_literal: true

module Mutations
  module Groups
    module PackageSettings
      class Update < Mutations::BaseMutation
        include ResolvesProject

        graphql_name 'UpdatePackageSettings'

        authorize :admin_group

        argument :group_path,
                GraphQL::ID_TYPE,
                required: true,
                description: 'The group path where the group package setting is located.'

        argument :maven_duplicates_allowed,
                GraphQL::BOOLEAN_TYPE,
                required: false,
                description: copy_field_description(Types::Groups::PackageSettingType, :maven_duplicates_allowed)

        argument :maven_duplicate_exception_regex,
                Types::UntrustedRegexp,
                required: false,
                description: copy_field_description(Types::Groups::PackageSettingType, :maven_duplicate_exception_regex)

        field :package_setting,
              Types::Groups::PackageSettingType,
              null: true,
              description: 'The group package setting after mutation.'

        def resolve(group_path:, **args)
          group = authorized_find!(full_path: project_path)

          result = ::Group::PackageSettings::UpdateService
            .new(container: group, current_user: current_user, params: args)
            .execute

          {
            package_setting: result.payload[:package_setting],
            errors: result.errors
          }
        end

        private

        def find_object(full_path:)
          resolve_project(full_path: full_path)
        end
      end
    end
  end
end
