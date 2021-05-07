# frozen_string_literal: true

module EE
  module Gitlab
    module Checks
      module PushRules
        class TagCheck < ::Gitlab::Checks::BaseChecker
          def validate_change!(oldrev, newrev, ref)
            return unless push_rule

            tag_name = Gitlab::Git.tag_name(ref)

            logger.log_timed("Checking if you are allowed to delete a tag...") do
              if tag_deletion_denied_by_push_rule?(oldrev, newrev, tag_name)
                raise ::Gitlab::GitAccess::ForbiddenError, 'You cannot delete a tag'
              end
            end
          end

          private

          def tag_deletion_denied_by_push_rule?(oldrev, newrev, tag_name)
            push_rule.deny_delete_tag &&
              !updated_from_web? &&
              deletion?(oldrev, newrev) &&
              tag_exists?(tag_name)
          end
        end
      end
    end
  end
end
