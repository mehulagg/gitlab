# frozen_string_literal: true

module Ci
  class BuildReportResultsService
    def execute(build)
      return unless Feature.enabled?(:ci_build_report_results, build.project)

      BuildReportResults.create(
        build_id: build.id,
        project_id: build.project_id,
        data: data_params(build)
      )
    end

    private

    def generate_test_suite_report(build)
      build.collect_test_reports!(Gitlab::Ci::Reports::TestReports.new)
    end

    def data_params(build)
      test_suite  = generate_test_suite_report(build)

      {
        junit: {
          name: test_suite.name,
          duration: test_suite.total_time,
          failed: test_suite.failed_count,
          errored: test_suite.error_count,
          skipped: test_suite.skipped_count,
          success: test_suite.success_count
        }
      }
    end
  end
end
