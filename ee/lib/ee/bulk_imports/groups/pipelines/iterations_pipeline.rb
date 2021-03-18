# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class IterationsPipeline
          include ::BulkImports::Pipeline

          extractor ::BulkImports::Common::Extractors::GraphqlExtractor,
            query: EE::BulkImports::Groups::Graphql::GetIterationsQuery

          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer

          def load(context, data)
            return unless data

            raise ::BulkImports::Pipeline::NotAllowedError unless authorized?

            context.group.iterations.create!(data)
          end

          def after_run(extracted_data)
            tracker.update(
              has_next_page: extracted_data.has_next_page?,
              next_page: extracted_data.next_page
            )

            if extracted_data.has_next_page?
              run
            end
          end

          private

          def authorized?
            context.current_user.can?(:admin_iteration, context.group)
          end
        end
      end
    end
  end
end
