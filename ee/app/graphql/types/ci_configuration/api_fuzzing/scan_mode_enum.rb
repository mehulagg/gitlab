# frozen_string_literal: true

module Types
  module CiConfiguration
    module ApiFuzzing
      class ScanModeEnum < BaseEnum
        graphql_name 'ApiFuzzingScanMode'

        ::Security::ApiFuzzing::CiConfiguration::SCAN_MODES.each do |mode|
          value mode.upcase, value: mode, description: "The API surface is specified by a #{mode.upcase} file."
        end
      end
    end
  end
end
