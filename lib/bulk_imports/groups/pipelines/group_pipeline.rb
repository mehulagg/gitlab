# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class GroupPipeline
        include Pipeline

        extractor Common::Extractors::GraphqlExtractor.new(
          query: Graphql::GetGroupQuery
        )

        transformer Common::Transformers::GraphqlCleanerTransformer.new
        transformer Common::Transformers::UnderscorifyKeysTransformer.new
        transformer Groups::Transformers::GroupAttributesTransformer.new

        loader Groups::Loaders::GroupLoader.new
      end
    end
  end
end
