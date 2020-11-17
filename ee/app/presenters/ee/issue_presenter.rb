# frozen_string_literal: true

module EE
  module IssuePresenter
    extend ActiveSupport::Concern

    def sla_due_at
      return unless sla_available?

      issuable_sla&.due_at
    end

    def web_url
      return super unless issue.issue_type == 'test_case'

      project_quality_test_case_url(issue.project, issue)
    end
  end
end
