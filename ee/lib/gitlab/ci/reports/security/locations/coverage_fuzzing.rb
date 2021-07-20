# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Locations
          class CoverageFuzzing < Base
            attr_reader :crash_address
            attr_reader :crash_type
            attr_reader :crash_state

            def initialize(crash_address:, crash_type:, crash_state:)
              @crash_address = crash_address
              @crash_type = crash_type
              @crash_state = crash_state
            end

            def fingerprint_data
              "#{crash_type}:#{crash_state}"
            end
          end
        end
      end
    end
  end
end
