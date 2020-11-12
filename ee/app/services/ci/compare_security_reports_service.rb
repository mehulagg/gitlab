# frozen_string_literal: true

module Ci
  class CompareSecurityReportsService < ::Ci::CompareReportsBaseService
    def comparer_class
      Gitlab::Ci::Reports::Security::VulnerabilityReportsComparer
    end

    def serializer_class
      Vulnerabilities::FindingDiffSerializer
    end

    def get_report(pipeline)
      Security::PipelineVulnerabilitiesFinder.new(pipeline: pipeline, params: { report_type: [params[:report_type]], scope: 'all' }).execute
    end
  end
end
