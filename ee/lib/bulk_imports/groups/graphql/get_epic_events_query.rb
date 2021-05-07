# frozen_string_literal: true

module BulkImports
  module Groups
    module Graphql
      module GetEpicEventsQuery
        extend self

        def to_s
          <<-'GRAPHQL'
          query($full_path: ID!, $epic_iid: ID!, $cursor: String, $per_page: Int) {
            group(fullPath: $full_path) {
              epic(iid: $epic_iid) {
                events(first: $per_page, after: $cursor) {
                  page_info: pageInfo {
                    next_page: endCursor
                    has_next_page: hasNextPage
                  }
                  nodes {
                    action
                    created_at: createdAt
                    updated_at: updatedAt
                    author {
                      public_email: publicEmail
                    }
                  }
                }
              }
            }
          }
          GRAPHQL
        end

        def variables(context)
          iid = context.extra[:epic_iid]

          {
            full_path: context.entity.source_full_path,
            cursor: context.tracker.next_page,
            epic_iid: iid,
            per_page: ::BulkImports::Tracker::DEFAULT_PAGE_SIZE
          }
        end

        def data_path
          base_path << 'nodes'
        end

        def page_info_path
          base_path << 'page_info'
        end

        private

        def base_path
          %w[data group epic events]
        end
      end
    end
  end
end
