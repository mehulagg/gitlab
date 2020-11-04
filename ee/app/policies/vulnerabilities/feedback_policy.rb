# frozen_string_literal: true

module Vulnerabilities
  class FeedbackPolicy < BasePolicy
    delegate { @subject.project }

    condition(:issue) { @subject.for_issue? }
    condition(:merge_request) { @subject.for_merge_request? }
    condition(:dismissal) { @subject.for_dismissal? }

    with_options scope: :user, score: 0
    condition(:security_bot) { @user&.security_bot? }

    rule { issue & ~can?(:create_issue) }.prevent :create_vulnerability_feedback

    rule do
      merge_request &
        ~security_bot &
        (~can?(:create_merge_request_in) | ~can?(:create_merge_request_from))
    end.prevent :create_vulnerability_feedback

    rule { ~dismissal }.prevent :destroy_vulnerability_feedback, :update_vulnerability_feedback
  end
end
