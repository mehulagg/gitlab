# frozen_string_literal: true

module BulkImports
  module Groups
    module Graphql
      module GetEpicsQuery
        extend self

        def to_s
          <<-'GRAPHQL'
          query($full_path: ID!) {
            group(fullPath: $full_path) {
              epics {
                edges {
                  node {
                    id
                    confidential
                    title
                    description
                    state
                    upvotes
                    downvotes
                    relativePosition
                    healthStatus {
                      issuesAtRisk
                      issuesNeedingAttention
                      issuesOnTrack
                    }
                    dueDate
                    dueDateFixed
                    dueDateIsFixed
                    dueDateFromMilestones
                    startDate
                    startDateFixed
                    startDateIsFixed
                    startDateFromMilestones
                    closedAt
                    createdAt
                  }
                }
              }
            }
          }
          GRAPHQL
        end

        def variables
          { full_path: :source_full_path }
        end
      end
    end
  end
end
