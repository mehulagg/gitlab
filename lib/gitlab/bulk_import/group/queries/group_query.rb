# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Group
      module Queries
        GroupQuery = ->(client) do
          client.parse <<-'GRAPHQL'
            query($project: ID!) {
              project(fullPath:$project) {
                  issues(first: 1) {
                    edges {
                      node {
                        assignees {
                          edges {
                            node {
                              email
                            }
                          }
                        }
                        discussions {
                          edges {
                            node {
                              id
                              notes {
                                edges {
                                  node {
                                    body
                                    system
                                    confidential
                                    author {
                                      email
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                        author {
                          email
                        }
                        createdAt
                        closedAt
                        confidential
                        createdAt
                        description
                        discussionLocked
                        dueDate
                        healthStatus
                        relativePosition
                        state
                        statusPagePublishedIncident
                        timeEstimate
                        title
                        type
                        updatedAt
                        weight
                      }
                    }
                  }
                }
            }
          GRAPHQL
        end
      end
    end
  end
end
