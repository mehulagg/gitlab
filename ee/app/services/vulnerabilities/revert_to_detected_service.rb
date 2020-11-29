# frozen_string_literal: true

require_dependency 'vulnerabilities/base_service'

module Vulnerabilities
  class RevertToDetectedService < BaseService
    REVERT_PARAMS = { resolved_by: nil, resolved_at: nil, dismissed_by: nil, dismissed_at: nil, confirmed_by: nil, confirmed_at: nil }.freeze

    def execute
      raise Gitlab::Access::AccessDeniedError unless authorized?

      @vulnerability.transaction do
        DestroyDismissalFeedbackService.new(@user, @vulnerability).execute

        update_with_note(@vulnerability, state: Vulnerability.states[:detected], **REVERT_PARAMS)
      end

      @vulnerability
    end
  end
end
