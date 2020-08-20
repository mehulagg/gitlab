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
                }
                blocked
                closedAt
                confidential
                createdAt
                description
                descriptionHtml
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
                titleHtml
                totalTimeSpent
                type
                updatedAt
                upvotes
                userNotesCount
                webPath
                webUrl
                weight
              }
            }
          }
        }
      }
    GRAPHQL

    def extract
      ::Gitlab::ImportExport::V2::Project::Graphql::Client.query(IssuesQuery, variables: { project: 'georgekoltsov/alfred-gitlab' })
    end
  end
end
