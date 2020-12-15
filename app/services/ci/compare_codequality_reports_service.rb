# frozen_string_literal: true

module Ci
  class CompareCodequalityReportsService < CompareReportsBaseService
    def execute(base_pipeline, head_pipeline)
      if Feature.enabled?(:codequality_mr_diff, project)
        merge_request = MergeRequest.find_by_id(params[:id])
        {
          status: :parsed,
          key: key(base_pipeline, head_pipeline),
          data: head_pipeline.pipeline_artifacts.find_with_codequality.present.for_files(merge_request.new_paths)
        }
      rescue => e
        Gitlab::ErrorTracking.track_exception(e, project_id: project.id)
        {
          status: :error,
          key: key(base_pipeline, head_pipeline),
          status_reason: _('An error occurred while fetching codequality reports.')
        }
      else
        super
      end
    end

    def latest?(base_pipeline, head_pipeline, data)
      data&.fetch(:key, nil) == key(base_pipeline, head_pipeline)
    end

    def comparer_class
      Gitlab::Ci::Reports::CodequalityReportsComparer
    end

    def serializer_class
      CodequalityReportsComparerSerializer
    end

    def get_report(pipeline)
      pipeline&.codequality_reports
    end
  end
end
