# frozen_string_literal: true

module Security
  class AutoFixService
    attr_reader :project

    def initialize(project)
      @project = project
    end

    def execute(vulnerability_ids)
      return if auto_fix_enabled_types.empty?

      vulnerabilities = Vulnerabilities::Finding.where(id: vulnerability_ids, report_type: auto_fix_enabled_types)

      vulnerabilities.each do |vulnerability|
        next if !!vulnerability.finding.merge_request_feedback.try(:merge_request_iid)

        remediation = vulnerability.remediations.last
        next if remediation

        VulnerabilityFeedback::CreateService.new(project, User.support_bot, service_params(vulnerability))

      end
    end

    private

    def auto_fix_enabled_types
      return if @auto_fix_enabled_types

      setting ||= ProjectSecuritySetting.safe_find_or_create_for(project)
      @auto_fix_enabled_types = setting.auto_fix_enabled
    end

    def service_params(vulnerability)
      {
        feedback_type: :merge_request,

      }
    end
  end
end
