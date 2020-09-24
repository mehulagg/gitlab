# frozen_string_literal: true

module Vulnerabilities
  class DismissService < BaseService
    include Gitlab::Allowable

    FindingsDismissResult = Struct.new(:ok?, :finding, :message)

    def initialize(current_user, vulnerability, comment = nil)
      super(current_user, vulnerability)
      @comment = comment
    end

    def execute
      raise Gitlab::Access::AccessDeniedError unless authorized?

      @vulnerability.transaction do
        result = dismiss_findings

        unless result.ok?
          handle_finding_dismissal_error(result.finding, result.message)
          raise ActiveRecord::Rollback
        end

        update_with_note(@vulnerability, state: Vulnerability.states[:dismissed], dismissed_by: @user, dismissed_at: Time.current)
      end

      @vulnerability
    end

    private

    def feedback_service_for(finding)
      VulnerabilityFeedback::CreateService.new(@project, @user, feedback_params_for(finding))
    end

    def feedback_params_for(finding)
      {
        category: finding.report_type,
        feedback_type: 'dismissal',
        project_fingerprint: finding.project_fingerprint,
        comment: @comment
      }
    end

    def dismiss_findings
      @vulnerability.findings.each do |finding|
        result = feedback_service_for(finding).execute

        return FindingsDismissResult.new(false, finding, result[:message]) if result[:status] == :error
      end

      FindingsDismissResult.new(true)
    end

    def handle_finding_dismissal_error(finding, message)
      @vulnerability.errors.add(
        :base,
        :finding_dismissal_error,
        message: _("failed to dismiss associated finding(id=%{finding_id}): %{message}") %
          {
            finding_id: finding.id,
            message: message
          })
    end
  end
end
