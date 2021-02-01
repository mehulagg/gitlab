# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Loaders
        class EpicsLoader
          def initialize(options = {})
            @options = options
          end

          def load(context, data)
            ::Epics::CreateService.new(
              context.entity.group,
              context.current_user,
              data
            ).execute
          end
        end
      end
    end
  end
end
