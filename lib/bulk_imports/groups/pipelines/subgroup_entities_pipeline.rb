# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class SubgroupEntitiesPipeline
        include Pipeline

        extractor BulkImports::Groups::Extractors::SubgroupsExtractor.new
        transformer BulkImports::Groups::Transformers::SubgroupToEntityTransformer.new
        loader BulkImports::Common::Loaders::EntityLoader.new
      end
    end
  end
end
