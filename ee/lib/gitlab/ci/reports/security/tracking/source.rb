# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Tracking
          class Source < Base
            attr_reader :file_path
            attr_reader :start_line
            attr_reader :end_line

            def initialize(file_path:, start_line:, end_line:)
              @file_path = file_path
              @start_line = start_line
              @end_line = end_line
            end

            private

            def fingerprint_data
              "#{file_path}:#{start_line}:#{end_line}"
            end
          end
        end
      end
    end
  end
end
