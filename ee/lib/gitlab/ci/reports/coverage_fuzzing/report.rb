# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module CoverageFuzzing
        class Report
          attr_reader :regression
          attr_reader :exit_code
          attr_reader :crashes

          def initialize
            @crashes = []
          end

          def add_crash(crash)
            @crashes << Crash.new(crash)
          end
        end
      end
    end
  end
end
