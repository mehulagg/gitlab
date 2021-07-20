# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class IterationsPipeline
        include ::BulkImports::Pipeline

        extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
          query: ::BulkImports::Groups::Graphql::GetIterationsQuery

        transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer

        def load(context, data)
          return unless data

          raise ::BulkImports::Pipeline::NotAllowedError unless authorized?

          context.group.iterations.create!(data)
        end

        private

        def authorized?
          context.current_user.can?(:admin_iteration, context.group)
        end
      end
    end
  end
end
