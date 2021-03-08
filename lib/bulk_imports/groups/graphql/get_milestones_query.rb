# frozen_string_literal: true

module BulkImports
  module Groups
    module Graphql
      module GetMilestonesQuery
        extend self

        def to_s
          <<-'GRAPHQL'
          query ($full_path: ID!, $cursor: String) {
            group(fullPath: $full_path) {
              milestones(first: 100, after: $cursor, includeDescendants: false) {
                page_info: pageInfo {
                  end_cursor: endCursor
                  has_next_page: hasNextPage
                }
                nodes {
                  title
                  description
                  state
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
            cursor: context.entity.next_page_for(:milestones)
          }
        end

        def base_path
          %w[data group milestones]
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
