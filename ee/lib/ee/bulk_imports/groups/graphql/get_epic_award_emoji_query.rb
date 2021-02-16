# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Graphql
        module GetEpicAwardEmojiQuery
          extend self

          def to_s
            <<-'GRAPHQL'
            query($full_path: ID!, $epic_iid: ID!, $cursor: String) {
              group(fullPath: $full_path) {
                epic(iid: $epic_iid) {
                  award_emoji: awardEmoji(first: 100, after: $cursor) {
                    page_info: pageInfo {
                      end_cursor: endCursor
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
            tracker = "epic_#{iid}_award_emoji"

            {
              full_path: context.entity.source_full_path,
              cursor: context.entity.next_page_for(tracker),
              epic_iid: iid
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
