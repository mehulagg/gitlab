# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicAwardEmojiPipeline
          include ::BulkImports::Pipeline

          def initialize(context)
            @context = context

            iids = context.group.epics.order(iid: :desc).pluck(:iid)
            context.extra[:epic_iid] = iids.pop
            context.extra[:epics_iids] = iids
          end

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicAwardEmojiQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer
          transformer EE::BulkImports::Groups::Transformers::EpicAwardEmojiTransformer

          loader EE::BulkImports::Groups::Loaders::EpicAwardEmojiLoader

          def after_run(context, extracted_data)
            iid = context.extra[:epic_iid]
            tracker = :"epic_#{iid}_award_emoji"

            context.entity.update_tracker_for(
              relation: tracker,
              has_next_page: extracted_data.has_next_page?,
              next_page: extracted_data.next_page
            )

            set_next_epic unless extracted_data.has_next_page?

            if extracted_data.has_next_page? || context.extra[:epic_iid]
              run
            end
          end

          def set_next_epic
            context.extra[:epic_iid] = context.extra[:epics_iids].pop
          end
        end
      end
    end
  end
end
