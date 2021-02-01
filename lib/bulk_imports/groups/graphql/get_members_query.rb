# frozen_string_literal: true

module BulkImports
  module Groups
    module Graphql
      module GetMembersQuery
        extend self
        def to_s
          <<-'GRAPHQL'
          query groupMembers($full_path: ID!, $cursor: String) {
            group(fullPath: $full_path) {
              groupMembers(relations: DIRECT, first: 100, after: $cursor) {
                page_info: pageInfo {
                  end_cursor: endCursor
                  has_next_page: hasNextPage
                }
                nodes {
                  created_at: createdAt
                  updated_at: updatedAt
                  expires_at: expiresAt
                  access_level: accessLevel {
                    integer_value: integerValue
                  }
                  user {
                    public_email: publicEmail
                  }
                }
              }
            }
          }
          GRAPHQL
        end

        def variables(entity)
          {
            full_path: entity.source_full_path,
            cursor: entity.next_page_for(:group_members)
          }
        end

        def base_path
          %w[data group group_members]
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
