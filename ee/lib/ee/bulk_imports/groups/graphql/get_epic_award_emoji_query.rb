# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Graphql
        module GetEpicAwardEmojiQuery
          extend self

          def to_s(emoji_pages)
            <<-GRAPHQL
            query($full_path: ID!) {
              group(fullPath: $full_path) {
                #{epics(emoji_pages)}
              }
            }
            GRAPHQL
          end

          def variables(context)
            {
              full_path: context.entity.source_full_path,
            }
          end

          def data_path
            base_path << 'group'
          end

          private

          def base_path
            %w[data]
          end

          def epics(emoji_pages)
            emoji_pages.map do |page|
              epic_iid = page.first
              next_page = page.last

              <<-GRAPHQL
                epic_#{epic_iid}: epic(iid: #{epic_iid}) {
                  iid
                  awardEmoji(first: 50, after: "#{next_page}") {
                    pageInfo {
                      has_next_page: hasNextPage
                      next_page: endCursor
                    }
                    nodes {
                      name
                      user {
                        public_email: publicEmail
                      }
                    }
                  }
                }
              GRAPHQL
            end.join("\n")
          end
        end
      end
    end
  end
end
