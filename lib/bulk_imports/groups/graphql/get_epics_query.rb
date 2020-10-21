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
                    title
                    description
                    state
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
