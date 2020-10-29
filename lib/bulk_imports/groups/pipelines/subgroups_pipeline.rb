# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class SubgroupsPipeline
        include Pipeline

        extractor BulkImports::Groups::Extractors::SubgroupsExtractor
        transformer BulkImports::Groups::Transformers::SubgroupsTransformer
        loader BulkImports::Groups::Loaders::SubgroupsLoader
      end
    end
  end
end
