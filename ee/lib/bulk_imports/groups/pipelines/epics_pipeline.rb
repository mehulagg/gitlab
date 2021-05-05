# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class EpicsPipeline
        include ::BulkImports::Pipeline

        extractor ::BulkImports::Common::Extractors::NdjsonExtractor, relation: :epics

        transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer
        transformer ::BulkImports::Common::Transformers::UserReferenceTransformer, reference: 'author'
        transformer ::BulkImports::Groups::Transformers::EpicAttributesTransformer

        def load(context, data)
          raise ::BulkImports::Pipeline::NotAllowedError unless authorized?

          context.group.epics.create!(data)
        end

        private

        def authorized?
          context.current_user.can?(:admin_epic, context.group)
        end
      end
    end
  end
end
