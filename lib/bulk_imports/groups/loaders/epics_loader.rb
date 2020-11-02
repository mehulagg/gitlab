# frozen_string_literal: true

module BulkImports
  module Groups
    module Loaders
      class EpicsLoader
        def initialize(options = {})
          @options = options
        end

        def load(context, data)
          Array(data["epics"]).each do |args|
            ::Epics::CreateService.new(
              context.entity.group,
              context.current_user,
              args
            ).execute
          end
        end
      end
    end
  end
end
