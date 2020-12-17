# frozen_string_literal: true

module EE
  module Boards
    module UpdateService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(board)
        unless parent.feature_available?(:scoped_issue_board)
          params.delete(:milestone_id)
          params.delete(:iteration_id)
          params.delete(:assignee_id)
          params.delete(:label_ids)
          params.delete(:labels)
          params.delete(:weight)
          params.delete(:hide_backlog_list)
          params.delete(:hide_closed_list)
        end

        filter_assignee
        filter_labels
        filter_milestone
        filter_iteration

        super
      end
    end
  end
end
