# frozen_string_literal: true

module Ci
  class CompareTestReportsService < CompareReportsBaseService
    def comparer_class
      Gitlab::Ci::Reports::TestReportsComparer
    end

    def serializer_class
      TestReportsComparerSerializer
    end

    def build_comparer(base_pipeline, head_pipeline)
      base_report = get_report(base_pipeline)
      head_report = get_report(head_pipeline)

      # We need to load the test failure history for the head report because we display
      # this on the MR widget
      head_report.load_test_failure_history!(head_pipeline.project)

      comparer_class.new(base_report, head_report)
    end

    def get_report(pipeline)
      pipeline&.test_reports
    end
  end
end
