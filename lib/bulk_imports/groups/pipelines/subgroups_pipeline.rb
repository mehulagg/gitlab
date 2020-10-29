# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class SubgroupsPipeline
        include Pipeline

        extractor BulkImports::Groups::Extractors::SubgroupsExtractor
        transformer BulkImports::Groups::Transformers::SubgroupsTransformer
        loader BulkImports::Common::Loaders::EntitiesLoader
      end
    end
  end
end
