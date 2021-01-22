# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicsPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicsQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer

          loader EE::BulkImports::Groups::Loaders::EpicsLoader

          def after_run(context, extracted_data)
            context.entity.update_tracker_for(
              relation: :epics,
              has_next_page: extracted_data.has_next_page?,
              next_page: extracted_data.next_page
            )

            if extracted_data.has_next_page?
              run(context)
            end
          end
        end
      end
    end
  end
end
