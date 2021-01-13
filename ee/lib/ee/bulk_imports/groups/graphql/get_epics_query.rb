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
                  pageInfo {
                    endCursor
                    hasNextPage
                  }
                  nodes {
                    title
                    description
                    state
                    createdAt
                    closedAt
                    startDate
                    startDateFixed
                    startDateIsFixed
                    dueDateFixed
                    dueDateIsFixed
                    relativePosition
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
        end
      end
    end
  end
end
