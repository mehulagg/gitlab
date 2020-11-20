# frozen_string_literal: true

module BulkImports
  module EE
    module Groups
      module Pipelines
        class EpicsPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: BulkImports::EE::Groups::Graphql::GetEpicsQuery

          transformer ::BulkImports::Common::Transformers::HashKeyDigger,
            key_path: %w[data group epics]
          transformer ::BulkImports::Common::Transformers::UnderscorifyKeysTransformer

          loader BulkImports::EE::Groups::Loaders::EpicsLoader

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
