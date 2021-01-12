# frozen_string_literal: true

module Types
  class DastScanType < BaseObject
    graphql_name 'DastScanType'
    description 'Represents a DAST Scan'

    authorize :create_on_demand_dast_scan

    expose_permissions Types::PermissionTypes::DastSiteProfile

    field :id, ::Types::GlobalIDType[::DastScanType], null: false,
          description: 'ID of the scan.'

    field :name, GraphQL::STRING_TYPE, null: true,
          description: 'The name of the scan.'

    field :description, GraphQL::STRING_TYPE, null: true,
          description: 'The description of the scan.'

    field :dast_site_profile_id, ::Types::GlobalIDType[::DastSiteProfile], null: true,
          description: 'ID of the site profile to be used for the scan.'

    field :dast_scanner_profile_id, ::Types::GlobalIDType[::DastScannerProfile], null: true,
          description: 'ID of the scanner profile to be used for the scan.'

    field :edit_path, GraphQL::STRING_TYPE, null: true,
          description: 'Relative web path to the edit page of a scan.'

    def edit_path
      ''
    end
  end
end
