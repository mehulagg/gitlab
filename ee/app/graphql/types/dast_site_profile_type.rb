# frozen_string_literal: true

module Types
  class DastSiteProfileType < BaseObject
    graphql_name 'DastSiteProfile'
    description 'Represents a DAST Site Profile'

    authorize :read_on_demand_scans

    expose_permissions Types::PermissionTypes::DastSiteProfile

    field :id, ::Types::GlobalIDType[::DastSiteProfile], null: false,
          description: 'ID of the site profile.'

    field :profile_name, GraphQL::STRING_TYPE, null: true,
          description: 'The name of the site profile.',
          method: :name

    field :target_url, GraphQL::STRING_TYPE, null: true,
          description: 'The URL of the target to be scanned.'

    field :edit_path, GraphQL::STRING_TYPE, null: true,
          description: 'Relative web path to the edit page of a site profile.'

    field :validation_status, Types::DastSiteProfileValidationStatusEnum, null: true,
          description: 'The current validation status of the site profile.',
          method: :status

    field :normalized_target_url, GraphQL::STRING_TYPE, null: true,
          description: 'Normalized URL of the target to be scanned.'

    def target_url
      object.dast_site.url
    end

    def edit_path
      Rails.application.routes.url_helpers.edit_project_security_configuration_dast_profiles_dast_site_profile_path(object.project, object)
    end

    def normalized_target_url
      DastSiteValidation.get_normalized_url_base(object.dast_site.url)
    end
  end
end
