# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Group
      module Pipelines
        class GroupPipeline
          include Gitlab::BulkImport::PipelineAttributes
          include Gitlab::BulkImport::PipelineRunner

          extractor Gitlab::BulkImport::Common::Extractors::GraphqlExtractor

          transformer Gitlab::BulkImport::Common::Transformers::GraphqlCleanerTransformer
          transformer Gitlab::BulkImport::Common::Transformers::UnderscorifyKeysTransformer
          transformer Gitlab::BulkImport::Group::Transformers::GroupAttributesTransformer

          loader Gitlab::BulkImport::Group::Loaders::GroupLoader
        end
      end
    end
  end
end
