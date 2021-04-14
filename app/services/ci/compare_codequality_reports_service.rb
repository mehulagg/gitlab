# frozen_string_literal: true

module Ci
  class CompareCodequalityReportsService < CompareReportsBaseService
    include Gitlab::Utils::StrongMemoize

    def comparer_class
      Gitlab::Ci::Reports::CodequalityReportsComparer
    end

    def execute(base_pipeline, head_pipeline)
      generate_mr_diff_report!(comparer, head_pipeline)

      super
    end

    def serializer_class
      CodequalityReportsComparerSerializer
    end

    def get_report(pipeline)
      pipeline&.codequality_reports
    end

    private

    def base_report
      strong_memoize(:base_report) do
        get_report(base_pipeline)
      end
    end

    def head_report
      strong_memoize(:head_report) do
        get_report(head_pipeline)
      end
    end

    def comparer
      strong_memoize(:comparer) do
        build_comparer(base_report, head_report)
      end
    end

    def generate_mr_diff_report!(comparer, head_pipeline)
      ::Ci::PipelineArtifacts::CreateQualityReportWorker.perform_async(pipeline.id, comparer.new_errors)
    end
  end
end
