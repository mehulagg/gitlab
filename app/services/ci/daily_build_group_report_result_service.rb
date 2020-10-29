# frozen_string_literal: true

module Ci
  class DailyBuildGroupReportResultService
    def execute(pipeline)
      # We don't process dangling pipelines (e.g. child pipelines) directly
      # because they should not affect the ref status.
      return if include_child_pipeline_reports?(pipeline) && pipeline.dangling?

      DailyBuildGroupReportResult.upsert_reports(coverage_reports(pipeline))
    end

    private

    def coverage_reports(pipeline)
      base_attrs = {
        project_id: pipeline.project_id,
        ref_path: pipeline.source_ref_path,
        date: pipeline.created_at.to_date,
        last_pipeline_id: pipeline.id,
        default_branch: pipeline.default_branch?
      }

      builds_with_coverage(pipeline).group_by(&:group_name).map do |group_name, builds|
        base_attrs.merge(
          group_name: group_name,
          data: {
            'coverage' => average_coverage(builds)
          }
        )
      end
    end

    def builds_with_coverage(pipeline)
      if include_child_pipeline_reports?(pipeline)
        # Include any possible builds from dependent child pipelines. Child pipelines
        # created without `strategy:depend` won't have their reports discovered.
        pipeline.builds_in_self_and_descendants(while_dependent: true).with_coverage
      else
        pipeline.builds_with_coverage
      end
    end

    def average_coverage(builds)
      total_coverage = builds.reduce(0.0) { |sum, build| sum + build.coverage }
      (total_coverage / builds.size).round(2)
    end

    def include_child_pipeline_reports?(pipeline)
      Gitlab::Ci::Features.include_child_pipeline_jobs_in_reports?(pipeline.project)
    end
  end
end
