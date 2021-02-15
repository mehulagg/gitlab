# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Graphql
        module GetEpicEventsQuery
          extend self

          def to_s
            <<-'GRAPHQL'
            query($full_path: ID!, $epic_iid: ID!, $cursor: String) {
              group(fullPath: $full_path) {
                epic(iid: $epic_iid) {
                  events(first: 100, after: $cursor): {
                    page_info: pageInfo {
                      end_cursor: endCursor
                      has_next_page: hasNextPage
                    }
                    nodes {
                      action
                      created_at: createdAt
                      updated_at: updatedAt
                      user: author {
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
            tracker = "epic_#{iid}_events"

            {
              full_path: context.entity.source_full_path,
              cursor: context.entity.next_page_for(tracker),
              epic_iid: iid
            }
          end

          def base_path
            %w[data group epic events]
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
