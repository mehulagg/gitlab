# frozen_string_literal: true

module Security
  class AutoFixService
    include Gitlab::Utils::StrongMemoize

    attr_reader :project, :pipeline

    def initialize(project, pipeline)
      @project = project
      @pipeline = pipeline
    end

    def execute
      return if Feature.disabled?(:security_auto_fix)
      return if auto_fix_enabled_types.empty?

      vulnerabilities = pipeline.vulnerability_findings.by_report_types(auto_fix_enabled_types)

      vulnerabilities.each do |vulnerability|
        next if !!vulnerability.merge_request_feedback.try(:merge_request_iid)
        next unless vulnerability.remediations

        VulnerabilityFeedback::CreateService.new(project, User.security_bot, service_params(vulnerability)).execute
      end
    end

    private

    def auto_fix_enabled_types
      strong_memoize(:auto_fix_enabled_types) do
        setting = ProjectSecuritySetting.safe_find_or_create_for(project)
        setting.auto_fix_enabled_types
      end
    end

    def service_params(vulnerability)
      {
        feedback_type: :merge_request,
        category: vulnerability.report_type,
        project_fingerprint: vulnerability.project_fingerprint,
        vulnerability_data: {
          severity: vulnerability.severity,
          confidence: vulnerability.confidence,
          description: vulnerability.description,
          solution: vulnerability.solution,
          remediations: vulnerability.remediations,
          category: vulnerability.report_type,
          title: vulnerability.name,
          name: vulnerability.name,
          location: vulnerability.location,
          links: vulnerability.links,
          identifiers: vulnerability.identifiers.map { |i| i.attributes }
        }
      }
    end
  end
end
