# frozen_string_literal: true

require_dependency 'vulnerabilities/base_service'

module Vulnerabilities
  class RevertToDetectedService < BaseService
    REVERT_PARAMS = { resolved_by: nil, resolved_at: nil, dismissed_by: nil, dismissed_at: nil, confirmed_by: nil, confirmed_at: nil }.freeze

    def execute
      raise Gitlab::Access::AccessDeniedError unless authorized?

      @vulnerability.transaction do
        revert_result = revert_findings_to_detected_state
        raise ActiveRecord::Rollback unless revert_result

        update_with_note(@vulnerability, state: Vulnerability.states[:detected], **REVERT_PARAMS)
      end

      @vulnerability
    end

    private

    def destroy_feedback_for(finding)
      VulnerabilityFeedback::DestroyService
        .new(@project, @user, finding.dismissal_feedback)
        .execute
    end

    def revert_findings_to_detected_state
      @vulnerability
        .dismissed_findings
        .each do |finding|
          result = destroy_feedback_for(finding)

          unless result
            handle_finding_revert_error(finding)
            return false
          end
        end

      true
    end

    def handle_finding_revert_error(finding)
      @vulnerability.errors.add(
        :base,
        :finding_revert_to_detected_error,
        message: _("failed to revert associated finding(id=%{finding_id}) to detected") %
          {
            finding_id: finding.id
          })
    end
  end
end
