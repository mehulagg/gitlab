# frozen_string_literal: true

class TestReportResultsEntity < Grape::Entity
  expose :total_time
  expose :total_success
  expose :total_failed
  expose :total_errored
  expose :total_skipped

  expose :build_report_results, using: BuildReportResultsEntity, as: :test_suite_results
end
