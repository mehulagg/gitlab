# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Graphql
        module GetIterationsQuery
          extend self

          def to_s
            <<-'GRAPHQL'
            query($full_path: ID!, $cursor: String) {
              group(fullPath: $full_path) {
                iterations(first: 100, after: $cursor, includeAncestors: false) {
                  page_info: pageInfo {
                    end_cursor: endCursor
                    has_next_page: hasNextPage
                  }
                  nodes {
                    iid
                    title
                    description
                    state
                    start_date: startDate
                    due_date: dueDate
                    created_at: createdAt
                    updated_at: updatedAt
                  }
                }
              }
            }
            GRAPHQL
          end

          def variables(context)
            {
              full_path: context.entity.source_full_path,
              cursor: context.tracker.next_page
            }
          end

          def base_path
            %w[data group iterations]
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
