# frozen_string_literal: true

require_dependency 'vulnerabilities/base_service'

module Vulnerabilities
  class ConfirmService < BaseService
    def execute
      raise Gitlab::Access::AccessDeniedError unless authorized?

      @vulnerability.transaction do
        DestroyDismissalFeedbackService.new(@user, @vulnerability).execute

        update_with_note(@vulnerability, state: Vulnerability.states[:confirmed], confirmed_by: @user, confirmed_at: Time.current)
      end

      @vulnerability
    end
  end
end
