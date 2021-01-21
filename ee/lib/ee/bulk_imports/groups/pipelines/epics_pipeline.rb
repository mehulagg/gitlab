# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Pipelines
        class EpicsPipeline
          include ::BulkImports::Pipeline

          def extract(context)
            ::BulkImports::Common::Extractors::GraphqlExtractor
              .new(query: EE::BulkImports::Groups::Graphql::GetEpicsQuery)
              .extract(context)
          end

          transformer ::BulkImports::Common::Transformers::HashKeyDigger, key_path: %w[data group epics]
          transformer ::BulkImports::Common::Transformers::UnderscorifyKeysTransformer
          transformer ::BulkImports::Common::Transformers::ProhibitedAttributesTransformer

          def load(context, data)
            Array.wrap(data['nodes']).each do |args|
              ::Epics::CreateService.new(
                context.entity.group,
                context.current_user,
                args
              ).execute
            end

            context.entity.update_tracker_for(
              relation: :epics,
              has_next_page: data.dig('page_info', 'has_next_page'),
              next_page: data.dig('page_info', 'end_cursor')
            )
          end

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
