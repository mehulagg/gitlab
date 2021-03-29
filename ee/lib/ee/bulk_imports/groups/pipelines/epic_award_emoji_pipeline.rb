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
          transformer ::BulkImports::Common::Transformers::UserReferenceTransformer

          loader EE::BulkImports::Groups::Loaders::EpicAwardEmojiLoader

          # rubocop: disable CodeReuse/ActiveRecord
          def initialize(context)
            @context = context
            @group = context.group
            @epic_iids = @group.epics.order(iid: :desc).pluck(:iid)

            set_next_epic
          end

          private

          def after_run(extracted_data)
            set_next_epic unless extracted_data.has_next_page?

            if extracted_data.has_next_page? || context.extra[:epic_iid]
              run
            end
          end

          def set_next_epic
            context.extra[:epic_iid] = @epic_iids.pop
          end
          # rubocop: enable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
