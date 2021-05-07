# frozen_string_literal: true

module EE
  module Gitlab
    module Checks
      module PushRules
        class BranchCheck < ::Gitlab::Checks::BaseChecker
          ERROR_MESSAGE = "Branch name does not follow the pattern '%{branch_name_regex}'"
          LOG_MESSAGE = "Checking if branch follows the naming patterns defined by the project..."

          def validate_change!(oldrev, newrev, ref)
            return unless push_rule

            branch_name = Gitlab::Git.branch_name(ref)

            logger.log_timed(LOG_MESSAGE) do
              unless branch_name_allowed_by_push_rule?(oldrev, newrev, branch_name)
                message = ERROR_MESSAGE % { branch_name_regex: push_rule.branch_name_regex }
                raise ::Gitlab::GitAccess::ForbiddenError, message
              end
            end

            PushRules::CommitCheck.new(change_access).validate_change!(oldrev, newrev, ref)
          rescue ::PushRule::MatchError => e
            raise ::Gitlab::GitAccess::ForbiddenError, e.message
          end

          private

          def branch_name_allowed_by_push_rule?(oldrev, newrev, branch_name)
            return true if skip_branch_name_push_rule?(oldrev, newrev, branch_name)

            push_rule.branch_name_allowed?(branch_name)
          end

          def skip_branch_name_push_rule?(oldrev, newrev, branch_name)
            deletion?(oldrev, newrev) ||
              branch_name.blank? ||
              branch_name == project.default_branch
          end
        end
      end
    end
  end
end
