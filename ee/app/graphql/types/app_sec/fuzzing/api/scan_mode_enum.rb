# frozen_string_literal: true

module Types
  module AppSec
    module Fuzzing
      module API
        class ScanModeEnum < BaseEnum
          graphql_name 'ApiFuzzingScanMode'
          description 'All possible ways to specify the API surface for an API fuzzing scan.'

          ::AppSec::Fuzzing::API::CiConfiguration::SCAN_MODES.each do |mode|
            value mode.upcase, value: mode, description: "The API surface is specified by a #{mode.upcase} file."
          end
        end
      end
    end
  end
end
