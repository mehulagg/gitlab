# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class ReportsComparer
        include Gitlab::Utils::StrongMemoize

        STATUS_SUCCESS = 'success'
        STATUS_FAILED = 'failed'

        attr_reader :base_report, :head_report

        def initialize(base_report, head_report)
          @base_report = base_report
          @head_report = head_report
        end

        def status
          raise NotImplementedError
        end

        def existing_errors
          raise NotImplementedError
        end

        def new_errors
          raise NotImplementedError
        end

        def resolved_errors
          raise NotImplementedError
        end

        def errors_count
          raise NotImplementedError
        end

        def resolved_count
          raise NotImplementedError
        end

        def total_count
          raise NotImplementedError
        end
      end
    end
  end
end
