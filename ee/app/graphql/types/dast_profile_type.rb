# frozen_string_literal: true

module Types
  class DastProfileType < BaseObject
    graphql_name 'DastProfile'
    description 'Represents a DAST Profile'

    authorize :create_on_demand_dast_scan

    field :id, ::Types::GlobalIDType[::DastProfile], null: false,
          description: 'ID of the profile.'

    field :name, GraphQL::STRING_TYPE, null: true,
          description: 'The name of the profile.'

    field :description, GraphQL::STRING_TYPE, null: true,
          description: 'The description of the scan.'

    field :dast_site_profile, DastSiteProfileType, null: true,
          description: 'The associated site profile.'

    field :dast_scanner_profile, DastScannerProfileType, null: true,
          description: 'The associated scanner profile.'

    field :edit_path, GraphQL::STRING_TYPE, null: true,
          description: 'Relative web path to the edit page of a profile.'

    def edit_path
      Rails.application.routes.url_helpers.edit_project_on_demand_scan_path(object.project, object)
    end
  end
end
