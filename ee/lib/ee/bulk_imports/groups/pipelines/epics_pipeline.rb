# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicsPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicsQuery

          transformer ::BulkImports::Common::Transformers::HashKeyDigger, key_path: %w[data group epics]
          transformer ::BulkImports::Common::Transformers::UnderscorifyKeysTransformer
          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer

          loader EE::BulkImports::Groups::Loaders::EpicsLoader

          after_run do |context|
            if context.entity.has_next_page?(:epics)
              self.new.run(context)
            end
          end
        end
      end
    end
  end
end
