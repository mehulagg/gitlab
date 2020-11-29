# frozen_string_literal: true

require_dependency 'vulnerabilities/base_service'

module Vulnerabilities
  class ResolveService < BaseService
    def execute
      raise Gitlab::Access::AccessDeniedError unless authorized?

      @vulnerability.transaction do
        DestroyDismissalFeedbackService.new(@user, @vulnerability).execute

        update_with_note(@vulnerability, state: Vulnerability.states[:resolved], resolved_by: @user, resolved_at: Time.current)
      end

      @vulnerability
    end
  end
end
