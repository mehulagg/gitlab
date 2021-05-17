# frozen_string_literal: true

module EE
  module MergeRequests
    module UpdateAssigneesService
      def assignee_ids
        if project.licensed_feature_available?(:multiple_merge_request_assignees)
          params.fetch(:assignee_ids).reject { _1 == 0 }
        else
          super
        end
      end
    end
  end
end
