# frozen_string_literal: true

module Types
  module CiConfiguration
    module Fuzzing
      class ScanProfileEnum < BaseEnum
        graphql_name 'FuzzingScanProfile'
        description 'The default API fuzzing configurations provided by GitLab'

        value 'QUICK', value: 'Quick',
          description: 'Fuzzes occasionally times per parameter'
        value 'QUICK_10', value: 'Quick-10',
          description: 'Fuzzes 10 times per parameter'
        value 'MEDIUM_20', value: 'Medium-20',
          description: 'Fuzzes 20 times per parameter'
        value 'MEDIUM_50', value: 'Medium-50',
          description: 'Fuzzes 50 times per parameter'
        value 'LONG_100', value: 'Long-100',
          description: 'Fuzzes 100 times per parameter'
      end
    end
  end
end
