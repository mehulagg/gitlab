# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class EntityFinisher
        def initialize(context)
          @context = context
        end

        def run
          return if context.entity.finished?

          context.entity.finish!

          logger.info(entity_id: context.entity.id, message: 'Entity Finished')
        end

        private

        attr_reader :context

        def logger
          @logger ||= Gitlab::Import::Logger.build
        end
      end
    end
  end
end
