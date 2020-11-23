# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class CodequalityReportsComparer
        include Gitlab::Utils::StrongMemoize

        STATUS_SUCCESS = 'success'
        STATUS_FAILED = 'failed'

        attr_reader :base_reports, :head_reports

        def initialize(base_reports, head_reports)
          @base_reports = base_reports || CodequalityReports.new
          @head_reports = head_reports
        end

        def status
          head_reports.degradations_count > 0 ? STATUS_FAILED : STATUS_SUCCESS
        end

        def existing_errors
          strong_memoize(:existing_errors) do
            base_reports.all_degradations
          end
        end

        def new_errors
          strong_memoize(:new_errors) do
            head_reports.all_degradations - base_reports.all_degradations
          end
        end

        def resolved_errors
          strong_memoize(:resolved_errors) do
            base_reports.all_degradations - head_reports.all_degradations
          end
        end

        def errors_count
          head_reports.degradations_count
        end

        def resolved_count
          resolved_errors.size
        end

        def total_count
          existing_errors.size + new_errors.size
        end
      end
    end
  end
end
