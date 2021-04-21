# frozen_string_literal: true

module EE
  module MergeRequests
    module HandleAssigneesChangeService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(merge_request, _old_assignees, _options = {})
        super

        return unless merge_request.project.licensed_feature_available?(:code_review_analytics)

        ::Analytics::RefreshReassignData.new(merge_request).execute_async
      end
    end
  end
end
