# frozen_string_literal: true

module Vulnerabilities
  class IssueLinkPolicy < BasePolicy
    delegate { @subject.vulnerability&.project }

    condition(:issue_readable?) { Ability.allowed?(@user, :read_issue, @subject.issue) }

    rule { ~issue_readable? }.prevent :read_issue_link
  end
end
