# frozen_string_literal: true

module Mutations
  module GroupPackageSettings
    class Update < Mutations::BaseMutation
      include Mutations::ResolvesGroup

      graphql_name 'UpdateGroupPackageSettings'

      authorize :create_package_settings

      argument :group_path,
              GraphQL::ID_TYPE,
              required: true,
              description: 'The group path where the group package setting is located.'

      argument :maven_duplicates_allowed,
              GraphQL::BOOLEAN_TYPE,
              required: false,
              description: copy_field_description(Types::GroupPackageSettingType, :maven_duplicates_allowed)

      argument :maven_duplicate_exception_regex,
              Types::UntrustedRegexp,
              required: false,
              description: copy_field_description(Types::GroupPackageSettingType, :maven_duplicate_exception_regex)

      field :group_package_setting,
            Types::GroupPackageSettingType,
            null: true,
            description: 'The group package setting after mutation.'

      def resolve(group_path:, **args)
        group = authorized_find!(group_path: group_path)

        result = Groups::GroupPackageSetting::UpdateService
          .new(group, current_user, args)
          .execute

        {
          group_package_setting: result.payload[:group_package_setting],
          errors: result.errors
        }
      end

      private

      def find_object(group_path:)
        resolve_group(full_path: group_path)
      end
    end
  end
end
