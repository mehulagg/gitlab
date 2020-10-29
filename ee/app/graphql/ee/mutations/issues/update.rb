# frozen_string_literal: true

module EE
  module Mutations
    module Issues
      module Update
        extend ActiveSupport::Concern

        prepended do
          include ::Mutations::Issues::CommonEEMutationArguments

          argument :epic_id, ::Types::GlobalIDType[::Epic],
                   required: false,
                   loads: ::Types::EpicType,
                   description: 'The ID of the parent epic. NULL when removing the association'
        end

        def resolve(**args)
          if args.key?(:epic)
            args[:epic_id] = epic_id(args.delete(:epic))
          end

          super(**args)
        end

        private

        def epic_id(epic)
          return unless epic

          authorize_epic!(epic)
          epic.id
        end

        def authorize_epic!(epic)
          return if can?(:admin_epic, epic)

          raise_resource_not_available_error!
        end
      end
    end
  end
end
