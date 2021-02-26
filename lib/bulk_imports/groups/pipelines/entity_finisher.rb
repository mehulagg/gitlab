# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class EntityFinisher
        def initialize(context)
          @context = context
        end

        def run
          context.entity.finish!

          # This will only finish the bulk_import if
          # all its entities are finished.
          context.bulk_import.finish
        end

        private

        attr_reader :context
      end
    end
  end
end
