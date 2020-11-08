# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class GroupPipeline
        include Pipeline

        extractor Common::Extractors::GraphqlExtractor.new(
          Graphql::GetGroupQuery.new
        )

        transformer do |context, entry|
          data.dig(:data, :group)
        end

        transformer do |context, entry|
          data.deep_transform_keys { |key| key.underscore }
        end

        transformer Groups::Transformers::GroupAttributesTransformer.new

        loader Groups::Loaders::GroupLoader.new
      end
    end
  end
end
