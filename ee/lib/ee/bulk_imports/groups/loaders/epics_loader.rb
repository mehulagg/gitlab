# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Loaders
        class EpicsLoader
          NotAllowedError = Class.new(StandardError)

          def initialize(options = {})
            @options = options
          end

          def load(context, data)
            raise NotAllowedError unless authorized?(context)

            # Use `Epic` directly when creating new epics
            # instead of `Epics::CreateService` since several
            # attributes like author_id (which might not be current_user),
            # group_id, parent, children need to be custom set
            ::Epic.create!(data)
          end

          private

          def authorized?(context)
            Ability.allowed?(context.current_user, :admin_epic, context.group)
          end
        end
      end
    end
  end
end
