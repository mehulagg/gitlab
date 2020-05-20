# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      class TestReportResults
        attr_reader :build_report_results

        def initialize(build_report_results)
          @build_report_results = build_report_results
        end

        def total_time
          build_report_results.pluck(:data).map { |j| j["junit"]["duration"] }.sum
        end

        def total_success
          build_report_results.pluck(:data).map { |j| j["junit"]["success"] }.sum
        end

        def total_failed
          build_report_results.pluck(:data).map { |j| j["junit"]["failed"] }.sum
        end

        def total_errored
          build_report_results.pluck(:data).map { |j| j["junit"]["errored"] }.sum
        end

        def total_skipped
          build_report_results.pluck(:data).map { |j| j["junit"]["skipped"] }.sum
        end

        def total_count
          [total_success, total_failed, total_errored, total_skipped].sum
        end
      end
    end
  end
end
