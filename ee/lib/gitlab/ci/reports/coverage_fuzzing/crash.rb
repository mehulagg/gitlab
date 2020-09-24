# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module CoverageFuzzing
        class Crash
          attr_accessor :crash_address
          attr_accessor :crash_type
          attr_accessor :crash_state
          attr_reader :stacktrace_snippet

          def initialize(params = {})
            @crash_address = params.fetch(:crash_address)
            @crash_type = params.fetch(:crash_type)
            @crash_state = params.fetch(:crash_state)
            @stacktrace_snippet = params.fetch(:stacktrace_snippet)
          end

          def hash
            crash_state.hash
          end

          def eql?(other)
            other.state == state && other.crash_type == crash_type
          end
        end
      end
    end
  end
end
