# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Issues
        module IssueMoveList
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          EpicID = ::Types::GlobalIDType[::Epic]

          prepended do
            argument :epic_id, EpicID,
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
            # TODO: remove this line once the compatibility layer is removed
            # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
            coerce_global_id_arguments!(args)
            epic_arguments = args.slice(:epic_id).transform_values { |id| id&.model_id }

            super.merge!(epic_arguments)
          end
        end
      end
    end
  end
end
