# frozen_string_literal: true

module Vulnerabilities
  class ConfirmService < BaseService
    include Gitlab::Allowable

    def execute
      raise Gitlab::Access::AccessDeniedError unless authorized?

      @vulnerability.tap do |vulnerability|
        update_with_note(vulnerability, state: Vulnerability.states[:confirmed], confirmed_by: @user, confirmed_at: Time.current)
      end
    end
  end
end
