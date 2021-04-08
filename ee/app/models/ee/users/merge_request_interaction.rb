# frozen_string_literal: true

module EE
  module Users
    module MergeRequestInteraction
      def applicable_approval_rules
        return [] unless merge_request.project.licensed_feature_available?(:merge_request_approvers)

        merge_request.applicable_approval_rules_for_user(user.id)
      end
    end
  end
end
