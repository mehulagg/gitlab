# frozen_string_literal: true

module Types
  class GroupPackageSettingType < BaseObject
    graphql_name 'GroupPackageSetting'

    description 'The group level package registry settings'

    authorize :read_package_settings

    field :maven_duplicates_allowed, GraphQL::BOOLEAN_TYPE, null: false, description: 'Indicates whether duplicate Maven packages are allowed for this group.'
    field :maven_duplicate_exception_regex, Types::UntrustedRegexp, null: true, description: 'Packages with names matching this regex will be allowed when maven_duplicates_allowed is false.'
  end
end
