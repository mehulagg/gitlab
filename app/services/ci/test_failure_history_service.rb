# frozen_string_literal: true

module Ci
  class TestFailureHistoryService
    MAX_TRACKABLE_FAILURES = 200

    def execute(pipeline)
      project = pipeline.project

      return unless Feature.enabled?(:test_failure_history, project)
      return unless project.default_branch_or_master == pipeline.ref

      track_failures(project, pipeline.builds_with_failed_tests)
    end

    private

    def track_failures(project, failed_builds)
      return unless failed_builds.any?

      failed_test_cases = gather_failed_test_cases(failed_builds)

      return if failed_test_cases.size > MAX_TRACKABLE_FAILURES

      failed_test_cases.keys.each_slice(100) do |key_hashes|
        Ci::TestCase.transaction do
          ci_test_cases = Ci::TestCase.find_or_create_by_batch(project, key_hashes)
          failures = test_case_failures(ci_test_cases, failed_test_cases)

          Ci::TestCaseFailure.insert_all(failures)
        end
      end
    end

    def gather_failed_test_cases(failed_builds)
      failed_test_cases = {}

      failed_builds.each do |build|
        test_suite = generate_test_suite!(build)
        test_suite.failed.keys.each do |key|
          failed_test_cases[key] = build
        end
      end

      failed_test_cases
    end

    def generate_test_suite!(build)
      # Returns an instance of Gitlab::Ci::Reports::TestSuite
      build.collect_test_reports!(Gitlab::Ci::Reports::TestReports.new)
    end

    def total_failures(failed_test_cases)
      # We are counting the number of builds per test case and
      # not just the number of test case keys. This is because
      # it's possible that a certain test case was intentionally
      # run on multiple builds for some reason.
      failed_test_cases.values.flatten.size
    end

    def test_case_failures(ci_test_cases, failed_test_cases)
      ci_test_cases.map do |test_case|
        build = failed_test_cases[test_case.key_hash]

        {
          test_case_id: test_case.id,
          build_id: build.id,
          failed_at: build.finished_at
        }
      end
    end
  end
end
