# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicAwardEmojiPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicAwardEmojiQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer
          transformer EE::BulkImports::Groups::Transformers::EpicAwardEmojiTransformer

          loader EE::BulkImports::Groups::Loaders::EpicAwardEmojiLoader

          def after_run(context, extracted_data)
            iid = context.extra[:epic_iid]
            tracker = "epic_#{iid}_award_emoji".to_sym

            context.entity.update_tracker_for(
              relation: tracker,
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
