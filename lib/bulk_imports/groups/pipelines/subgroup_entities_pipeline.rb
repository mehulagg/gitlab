# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class SubgroupEntitiesPipeline
        include Pipeline

        extractor BulkImports::Groups::Extractors::SubgroupsExtractor
        transformer Common::Transformers::ProhibitedAttributesTransformer
        transformer BulkImports::Groups::Transformers::SubgroupToEntityTransformer

        def load(context, data)
          # Use the service to ensure the BulkImportWorker
          # will be called to import the new entities
          BulkImport::CreateEntityService
            .new(context.bulk_import, data)
        end
      end
    end
  end
end
