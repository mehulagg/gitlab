# frozen_string_literal: true

module Gitlab::ImportExport::V2::Project::Extractors
  class IssuesExtractor
    IssuesQuery = ::Gitlab::ImportExport::V2::Project::Graphql::Client.parse <<-'GRAPHQL'
      query($project: ID!) {
        project(fullPath: $project) {
          issues(first: 1) {
            edges {
              node {
                assignees {
                  edges {
                    node {
                      name
                    }
                  }
                }
                author {
                  id
                  email
                }
                closedAt
                confidential
                createdAt
                description
                discussionLocked
                discussions {
                  edges {
                    node {
                      id
                    }
                  }
                }
                downvotes
                dueDate
                epic {
                  id
                }
                healthStatus
                id
                iid
                iteration {
                  id
                }
                labels {
                  edges {
                    node {
                      id
                    }
                  }
                }
                milestone {
                  id
                }
                notes {
                  edges {
                    node {
                      id
                    }
                  }
                }
                participants {
                  edges {
                    node {
                      id
                    }
                  }
                }
                reference
                relativePosition
                state
                statusPagePublishedIncident
                subscribed
                timeEstimate
                title
                totalTimeSpent
                type
                updatedAt
                upvotes
                userNotesCount
                weight
              }
            }
          }
        }
      }
    GRAPHQL

    def extract(project:)
      ::Gitlab::ImportExport::V2::Project::Graphql::Client
        .query(IssuesQuery, variables: { project: project })
        .original_hash
    end
  end
end
