# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Graphql
        module GetEpicAwardEmojiQuery
          extend self

          def to_s
            <<-'GRAPHQL'
            query($full_path: ID!, $epic_iid: ID!, $cursor: String, $per_page: Int) {
              group(fullPath: $full_path) {
                epic(iid: $epic_iid) {
                  award_emoji: awardEmoji(first: $per_page, after: $cursor) {
                    page_info: pageInfo {
                      next_page: endCursor
                      has_next_page: hasNextPage
                    }
                    nodes {
                      name
                      user {
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
            %w[data group epic award_emoji]
          end
        end
      end
    end
  end
end
