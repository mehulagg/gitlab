# frozen_string_literal: true

module Gitlab::BulkImport::Pipelines
  class Group
    include ::Gitlab::BulkImport::PipelineAttributes

    extractor ::Gitlab::BulkImport::Base::Extractors::GraphqlExtractor

    transformer ::Gitlab::BulkImport::Base::Transformers::GraphqlCleanerTransformer

    def self.run(config)

    end
  end
end
