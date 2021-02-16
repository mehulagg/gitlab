# frozen_string_literal: true

module Types
  module CiConfiguration
    # rubocop: disable Graphql/AuthorizeTypes
    class ApiFuzzingType < BaseObject
      graphql_name 'ApiFuzzingCiConfiguration'
      description 'Data associated with configuring API fuzzing scans in GitLab CI'

      field :scan_modes, [ApiFuzzing::ScanModeEnum], null: true,
            description: 'All available scan modes.'

      field :scan_profiles, [ApiFuzzing::ScanProfileType], null: true,
            description: 'All default scan profiles.'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
