# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class TestReports
        include Gitlab::Utils::StrongMemoize

        attr_reader :test_suites

        def initialize
          @test_suites = {}
        end

        def get_suite(suite_name)
          test_suites[suite_name] ||= TestSuite.new(suite_name)
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def total_time
          test_suites.values.sum(&:total_time)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        # rubocop: disable CodeReuse/ActiveRecord
        def total_count
          test_suites.values.sum(&:total_count)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def total_status
          if failed_count > 0 || error_count > 0
            TestCase::STATUS_FAILED
          else
            TestCase::STATUS_SUCCESS
          end
        end

        def with_attachment!
          @test_suites.keep_if do |_job_name, test_suite|
            test_suite.with_attachment!.present?
          end

          self
        end

        def suite_errors
          test_suites.transform_values(&:suite_error).compact
        end

        # This method is not meant to be always called on every test report instance.
        # This is only needed to be called on test reports that are meant to include
        # test failure history on their test cases which will be shown on the UI.
        #
        # For example, on the MR widget which does comparison between base and head pipeline,
        # this method is only called on the head test report.
        #
        # Calling this method will populate each test case's recent_failures
        def load_test_failure_history!(project)
          recent_failures_count(project).each do |key_hash, count|
            failed_test_cases[key_hash].recent_failures_count = count
          end
        end

        TestCase::STATUS_TYPES.each do |status_type|
          define_method("#{status_type}_count") do
            # rubocop: disable CodeReuse/ActiveRecord
            test_suites.values.sum { |suite| suite.public_send("#{status_type}_count") } # rubocop:disable GitlabSecurity/PublicSend
            # rubocop: enable CodeReuse/ActiveRecord
          end
        end

        private

        def recent_failures_count(project)
          ::Ci::TestCaseFailure.recent_failures_count(project, failed_test_cases.keys)
        end

        def failed_test_cases
          strong_memoize(:failed_test_cases) do
            {}.tap do |map|
              test_suites.values.each do |test_suite|
                map.merge!(test_suite.failed)
              end
            end
          end
        end
      end
    end
  end
end
