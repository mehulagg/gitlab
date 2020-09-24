# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Issues
        module IssueMoveList
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          prepended do
            argument :epic_id, ::Types::GlobalIDType[::Epic],
                      required: false,
                      description: 'The ID of the parent epic. NULL when removing the association'
          end

          override :move_issue
          def move_issue(board, issue, move_params)
            super
          rescue ::Issues::BaseService::EpicAssignmentError => e
            issue.errors.add(:epic_issue, e.message)
          # because we can't be sure if these exceptions were raised because of epic
          # we return just a generic error here for now
          # https://gitlab.com/gitlab-org/gitlab/-/issues/247096
          rescue ::Gitlab::Access::AccessDeniedError, ActiveRecord::RecordNotFound
            issue.errors.add(:base, 'Resource not found')
          end

          override :move_arguments
          def move_arguments(args)
            allowed_args = super
            allowed_args[:epic_id] = args[:epic_id]&.model_id if args.has_key?(:epic_id)

            allowed_args
          end
        end
      end
    end
  end
end
