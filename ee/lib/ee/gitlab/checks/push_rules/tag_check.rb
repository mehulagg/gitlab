# frozen_string_literal: true

module EE
  module Gitlab
    module Checks
      module PushRules
        class TagCheck < ::Gitlab::Checks::BaseSingleChecker
          def validate!
            return unless push_rule

            logger.log_timed("Checking if you are allowed to delete a tag...") do
              if tag_deletion_denied_by_push_rule?
                raise ::Gitlab::GitAccess::ForbiddenError, 'You cannot delete a tag'
              end
            end
          end

          private

          def tag_deletion_denied_by_push_rule?
            push_rule.deny_delete_tag &&
              !updated_from_web? &&
              deletion? &&
              tag_exists?
          end
        end
      end
    end
  end
end
