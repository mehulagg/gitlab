# frozen_string_literal: true
module Ci
  module PipelineArtifacts
    class CreateCodeQualityMrDiffReportService
      def execute(pipeline, new_errors)
        return unless pipeline.can_generate_codequality_reports?
        return if pipeline.has_codequality_mr_diff_report?

        file = build_carrierwave_file(new_errors)

        pipeline.pipeline_artifacts.create!(
          project_id: pipeline.project_id,
          file_type: :code_quality_mr_diff,
          file_format: Ci::PipelineArtifact::REPORT_TYPES.fetch(:code_quality_mr_diff),
          size: file["tempfile"].size,
          file: file,
          expire_at: Ci::PipelineArtifact::EXPIRATION_DATE.from_now
        )
      end

      private

      def build_carrierwave_file(new_errors)
        CarrierWaveStringFile.new_file(
          file_content: build_quality_mr_diff_report(new_errors),
          filename: Ci::PipelineArtifact::DEFAULT_FILE_NAMES.fetch(:code_quality_mr_diff),
          content_type: 'application/json'
        )
      end

      def build_quality_mr_diff_report(new_errors)
        mr_diff_report = Gitlab::Ci::Reports::CodequalityMrDiff.new(new_errors)

        Ci::CodequalityMrDiffReportSerializer.new.represent(mr_diff_report).to_json # rubocop: disable CodeReuse/Serializer
      end
    end
  end
end
