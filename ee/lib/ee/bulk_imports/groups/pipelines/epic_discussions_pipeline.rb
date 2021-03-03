# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicDiscussionsPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::DiscussionsExtractor,
            query: EE::BulkImports::Groups::Graphql::GetEpicDiscussionsQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer
          transformer ::BulkImports::Common::Transformers::UserReferenceTransformer, reference: 'author'

          def initialize(context)
            @context = context
            @group = context.group
            @epic_iids = @group.epics.order(iid: :desc).pluck(:iid) # rubocop: disable CodeReuse/ActiveRecord

            set_next_epic
          end

          def after_run(extracted_data)
            iid = context.extra[:epic_iid]
            tracker = "epic_#{iid}_events"

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

          private

          def set_next_epic
            context.extra[:epic_iid] = @epic_iids.pop
          end
        end
      end
    end
  end
end
