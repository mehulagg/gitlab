# frozen_string_literal: true

module Types
  module CiConfiguration
    module Fuzzing
      class ScanModeEnum < BaseEnum
        graphql_name 'FuzzingScanMode'
        description 'The possible API file definition types that can be used to define the API surface for a fuzzing scan'

        value 'OPENAPI', value: 'OpenAPI',
          description: 'Mode that uses an OpenAPI specification file to define the API surface for scanning.'
        value 'HAR', value: 'HTTP Archive (HAR)',
          description: 'Mode that uses a HAR specification file to define the API surface for scanning'
      end
    end
  end
end
