# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Graphql
        module GetEpicsQuery
          extend self

          def to_s
            <<-'GRAPHQL'
            query($full_path: ID!, $cursor: String) {
              group(fullPath: $full_path) {
                epics(
                  includeDescendantGroups: false,
                  first: 100,
                  after: $cursor
                ) {
                  page_info: pageInfo {
                    end_cursor: endCursor
                    has_next_page: hasNextPage
                  }
                  nodes {
                    title
                    description
                    state
                    created_at: createdAt
                    closed_at: closedAt
                    start_date: startDate
                    start_date_fixed: startDateFixed
                    start_date_is_fixed: startDateIsFixed
                    due_date_fixed: dueDateFixed
                    due_date_is_fixed: dueDateIsFixed
                    relative_position: relativePosition
                    confidential
                  }
                }
              }
            }
            GRAPHQL
          end

          def variables(entity)
            {
              full_path: entity.source_full_path,
              cursor: entity.next_page_for(:epics)
            }
          end

          def base_path
            %w[data group epics]
          end

          def data_path
            base_path << 'nodes'
          end

          def page_info_path
            base_path << 'page_info'
          end
        end
      end
    end
  end
end
