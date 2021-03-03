# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Graphql
        module GetEpicDiscussionsQuery
          extend self

          def to_s
            <<-'GRAPHQL'
            query($full_path: ID!, $epic_iid: ID!, $discussions_cursor: String, $notes_cursor: String) {
              group(fullPath: $full_path) {
                epic(iid: $epic_iid) {
                  discussions(first: 1, after: $discussions_cursor) {
                    page_info: pageInfo {
                      end_cursor: endCursor
                      has_next_page: hasNextPage
                    }
                    nodes {
                      id
                      notes(first: 100, after: $notes_cursor) {
                        page_info: pageInfo {
                          end_cursor: endCursor
                          has_next_page: hasNextPage
                        }
                        nodes {
                          body
                        }
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
            discussions_tracker = "epic_#{iid}_discussions"
            notes_tracker = "epic_#{iid}_discussion_notes"


            {
              epic_iid: iid,
              full_path: context.entity.source_full_path,
              notes_cursor: context.entity.next_page_for(notes_tracker),
              discussions_cursor: context.entity.next_page_for(discussions_tracker)
            }
          end

          def discussions_data_path
            discussions_base_path << 'nodes'
          end

          def notes_data_path
            notes_base_path << 'nodes'
          end

          def discussions_page_info_path
            discussions_base_path << 'page_info'
          end

          def notes_page_info_path
            notes_base_path << 'page_info'
          end

          private

          def discussions_base_path
            %w[data group epic discussions]
          end

          def notes_base_path
            %w[data group epic discussions nodes 0 notes]
          end
        end
      end
    end
  end
end
