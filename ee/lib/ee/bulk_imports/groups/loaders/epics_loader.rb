# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Loaders
        class EpicsLoader
          def initialize(options = {})
            @options = options
          end

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
        end
      end
    end
  end
end
