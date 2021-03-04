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
          transformer EE::BulkImports::Groups::Transformers::EpicAttributesTransformer

          def load(context, data)
            raise ::BulkImports::Pipeline::NotAllowedError unless authorized?

            context.group.epics.create!(data)
          end

          def after_run(extracted_data)
            context.entity.update_tracker_for(
              relation: :epics,
              has_next_page: extracted_data.has_next_page?,
              next_page: extracted_data.next_page
            )

            if extracted_data.has_next_page?
              run
            end
          end

          private

          def authorized?
            context.current_user.can?(:admin_epic, context.group)
          end
        end
      end
    end
  end
end
