# frozen_string_literal: true

require_dependency 'vulnerabilities/base_service'

module Vulnerabilities
  class ResolveService < BaseService
    def execute
      raise Gitlab::Access::AccessDeniedError unless authorized?

      @vulnerability.tap do |vulnerability|
        update_with_note(vulnerability, state: Vulnerability.states[:resolved], resolved_by: @user, resolved_at: Time.current)
      end
    end
  end
end
