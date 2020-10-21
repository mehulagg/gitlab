# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class EpicsPipeline
        include Pipeline

        extractor Common::Extractors::GraphqlExtractor, query: Graphql::GetEpicsQuery

        transformer Common::Transformers::GraphqlCleanerTransformer
        transformer Common::Transformers::UnderscorifyKeysTransformer

        # loader Groups::Loaders::EpicsLoader
      end
    end
  end
end
