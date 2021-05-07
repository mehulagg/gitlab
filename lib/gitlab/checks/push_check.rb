# frozen_string_literal: true

module Gitlab
  module Checks
    class PushCheck < BaseChecker
      def validate_change!(oldrev, newrev, ref)
        logger.log_timed("Checking if you are allowed to push...") do
          unless can_push?(ref)
            raise GitAccess::ForbiddenError, GitAccess::ERROR_MESSAGES[:push_code]
          end
        end
      end

      private

      def can_push?(ref)
        user_access.can_push_for_ref?(ref) ||
          project.branch_allows_collaboration?(user_access.user, Gitlab::Git.branch_name(ref))
      end
    end
  end
end
