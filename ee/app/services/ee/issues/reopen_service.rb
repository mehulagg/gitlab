# frozen_string_literal: true

module EE
  module Issues
    module ReopenService
      extend ::Gitlab::Utils::Override

      override :before_reopen
      def before_reopen(issue)
        # Assign blocking_issues_count to issue object instead of performing an update,
        # this way we can keep issue#previous_changes attributes consistent.
        # Some services may use them to perform callbacks like StatusPage::TriggerPublishService
        issue.blocking_issues_count = ::IssueLink.blocking_issues_count_for(issue)

        super
      end
    end
  end
end
