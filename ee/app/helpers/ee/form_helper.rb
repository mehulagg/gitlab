# frozen_string_literal: true

module EE
  module FormHelper
    def issue_supports_multiple_assignees?
      current_board_parent.feature_available?(:multiple_issue_assignees)
    end

    def merge_request_supports_multiple_assignees?
      @merge_request&.allows_multiple_assignees?
    end

    def merge_request_supports_multiple_reviewers?
      @merge_request&.allows_multiple_reviewers?
    end
  end
end
