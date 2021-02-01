# frozen_string_literal: true

module Types
  module CiConfiguration
    module Sast
      class InputType < BaseInputObject
        graphql_name 'ApiFuzzingCiConfigurationInput'
        description 'API Fuzzing CI configuration details'

        argument :project_path, GraphQL::ID_TYPE,
          required: true,
          description: 'Full path of the project for which the API fuzzing scan is being configured.'

        argument :target, GraphQL::STRING_TYPE,
          required: true,
          description: 'The URL of the scan target.'

        argument :scan_mode, ScanModeType,
          required: true,
          description: ''
      end
    end
  end
end
