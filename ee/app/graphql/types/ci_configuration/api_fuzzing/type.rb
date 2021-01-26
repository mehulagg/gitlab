# frozen_string_literal: true

module Types
  module CiConfiguration
    module ApiFuzzing
      class Type < BaseObject
        graphql_name 'ApiFuzzingCiConfiguration'

        field :scan_modes, [ScanModeEnum], null: true,
              description: 'All available scan modes.'

        field :scan_profiles, [ScanProfile], null: true,
              description: 'All default scan profiles.'
      end
    end
  end
end
