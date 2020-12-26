# frozen_string_literal: true

module BulkImports
  module EE
    module Groups
      module Pipelines
        class EpicsPipeline
          include ::BulkImports::Pipeline

          def extract(context)
            Common::Extractors::GraphqlExtractor
              .new(query: BulkImports::EE::Groups::Graphql::GetEpicsQuery)
              .extract(context)
          end


          def transformer(context, entry)
            entry
              .dig('data', 'group', 'epics')
              .deep_transform_keys { |key| key.to_s.underscore }
              .then { |data| clean_prohibited_attributes(context, data) }
          end

          def load(context, entry)
            Array.wrap(entry['nodes']).each do |args|
              ::Epics::CreateService.new(
                context.entity.group,
                context.current_user,
                args
              ).execute
            end

            context.entity.update_tracker_for(
              relation: :epics,
              has_next_page: entry.dig('page_info', 'has_next_page'),
              next_page: entry.dig('page_info', 'end_cursor')
            )
          end
        end

        def after_run(context)
          if context.entity.has_next_page?(:epics)
            self.new.run(context)
          end
        end
      end
    end
  end
end
