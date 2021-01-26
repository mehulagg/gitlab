# frozen_string_literal: true

require_dependency 'vulnerabilities/base_service'

# This service class removes all the dismissal feedback
# associated with a vulnerability through it's findings.
module Vulnerabilities
  class DestroyDismissalFeedbackService < BaseService
    def execute
      @vulnerability.dismissed_findings.each do |finding|
        unless destroy_feedback_for(finding)
          handle_finding_revert_error(finding)
          raise ActiveRecord::Rollback
        end
      end
    end

    private

    def destroy_feedback_for(finding)
      VulnerabilityFeedback::DestroyService
        .new(@project, @user, finding.dismissal_feedback, revert_vulnerability_state: false)
        .execute
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
