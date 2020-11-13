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
            key_path: %w[data group epics nodes]
          transformer ::BulkImports::Common::Transformers::UnderscorifyKeysTransformer

          loader BulkImports::EE::Groups::Loaders::EpicsLoader

          after_run do |context, data|
            page_info = data.first.dig('data', 'page_info')

            context.entity.update_tracker_for(
              relation: :epics,
              has_next_page:  page_info['has_next_page'],
              next_page: page_info['end_cursor']
            )

            self.new.run(context) if page_info['has_next_page']
          end
        end
      end
    end
  end
end
