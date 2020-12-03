# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class CodequalityReportsComparer < ReportsComparer
        def initialize(base_report, head_report)
          @base_report = base_report || CodequalityReports.new
          @head_report = head_report
        end

        def status
          head_report.degradations_count > 0 ? STATUS_FAILED : STATUS_SUCCESS
        end

        def existing_errors
          strong_memoize(:existing_errors) do
            base_report.all_degradations
          end
        end

        def new_errors
          strong_memoize(:new_errors) do
            fingerprints = head_report.degradations.keys - base_report.degradations.keys

            head_report.degradations.select do |key, _value|
              fingerprints.include?(key)
            end.values
          end
        end

        def resolved_errors
          strong_memoize(:resolved_errors) do
            fingerprints = base_report.degradations.keys - head_report.degradations.keys

            base_report.degradations.select do |key, _value|
              fingerprints.include?(key)
            end.values
          end
        end

        def errors_count
          head_report.degradations_count
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
