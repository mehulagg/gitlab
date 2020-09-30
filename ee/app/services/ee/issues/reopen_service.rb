# frozen_string_literal: true

module EE
  module Issues
    module ReopenService
      extend ::Gitlab::Utils::Override

      override :after_reopen
      def after_reopen(issue)
        issue.update_blocking_issues_count!
        super
      end
    end
  end
end
