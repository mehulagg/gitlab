# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module LicenseScanning
        class ReportsComparer
          include Gitlab::Utils::StrongMemoize

          attr_reader :base_report, :head_report

          def initialize(base_report, head_report)
            @base_report = base_report
            @head_report = head_report
          end

          def new_licenses
            diff[:added]
          end

          def existing_licenses
            diff[:unchanged]
          end

          def removed_licenses
            diff[:removed]
          end

          private

          def diff
            strong_memoize(:diff) do
              base_report.diff_with(head_report)
            end
          end
        end
      end
    end
  end
end
