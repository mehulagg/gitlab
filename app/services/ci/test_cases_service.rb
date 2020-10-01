# frozen_string_literal: true

module Ci
  class TestCasesService
    MAX_TRACKABLE_FAILURES = 200

    def execute(build)
      return unless build.has_test_reports?

      test_suite = generate_test_suite_report(build)

      track_failures(build, test_suite)
    end

    private

    def generate_test_suite_report(build)
      build.collect_test_reports!(Gitlab::Ci::Reports::TestReports.new)
    end

    def track_failures(build, test_suite)
      return if test_suite.failed_count > MAX_TRACKABLE_FAILURES

      Ci::TestCaseFailure.insert_all(test_case_failures(build, test_suite))
    end

    def test_case_failures(build, test_suite)
      test_cases = Ci::TestCase.find_or_create_by_batch(build.project, test_suite.failed.keys)
      test_cases.map do |test_case|
        {
          test_case_id: test_case.id,
          ref_path: build.git_ref,
          build_id: build.id,
          failed_at: build.finished_at
        }
      end
    end
  end
end
