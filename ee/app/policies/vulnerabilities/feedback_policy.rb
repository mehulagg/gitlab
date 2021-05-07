# frozen_string_literal: true

module Vulnerabilities
  class FeedbackPolicy < BasePolicy
    delegate { @subject.project }

    condition(:issue) { @subject.for_issue? }
    condition(:merge_request) { @subject.for_merge_request? }
    condition(:dismissal) { @subject.for_dismissal? }
    condition(:auto_fix_enabled) { @subject.project.security_setting&.auto_fix_enabled? }

    rule { issue & ~can?(:create_issue) }.prevent :create_vulnerability_feedback

    rule do
      merge_request & ~can?(:create_merge_request_in)
    end.prevent :create_vulnerability_feedback

    # Prevent Security bot from creating vulnerability feedback
    # if auto-fix feature is disabled
    rule do
      merge_request &
        security_bot &
        ~auto_fix_enabled
    end.prevent :create_vulnerability_feedback

    rule { ~dismissal }.prevent :destroy_vulnerability_feedback, :update_vulnerability_feedback
  end
end
