# frozen_string_literal: true

module BulkImports
  module EE
    module Groups
      module Loaders
        class EpicsLoader
          def initialize(*args); end

          def load(context, entry)
            ::Epics::CreateService.new(
              context.entity.group,
              context.current_user,
              entry
            ).execute
          end
        end
      end
    end
  end
end
