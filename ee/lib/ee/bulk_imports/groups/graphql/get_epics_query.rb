# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Graphql
        module GetEpicsQuery
          extend self

          def to_s
            <<-'GRAPHQL'
            query($full_path: ID!, $cursor: String, $per_page: Int) {
              group(fullPath: $full_path) {
                epics(
                  includeDescendantGroups: false,
                  first: $per_page,
                  after: $cursor
                ) {
                  page_info: pageInfo {
                    next_page: endCursor
                    has_next_page: hasNextPage
                  }
                  nodes {
                    id
                    iid
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
                    author {
                      public_email: publicEmail
                    }
                    parent {
                      iid
                    }
                    children {
                      nodes {
                        iid
                      }
                    }
                    labels {
                      nodes {
                        title
                      }
                    }
                  }
                }
              }
            }
            GRAPHQL
          end

          def variables(context)
            {
              full_path: context.entity.source_full_path,
              cursor: context.tracker.next_page,
              per_page: ::BulkImports::Tracker::DEFAULT_PAGE_SIZE
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
