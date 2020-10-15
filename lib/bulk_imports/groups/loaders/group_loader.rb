# frozen_string_literal: true

module BulkImports
  module Groups
    module Loaders
      class GroupLoader
        def initialize(options = {})
          @options = options
        end

        def load(context, data)
          ::Groups::CreateService.new(context.current_user, data).execute
        end
      end
    end
  end
end
