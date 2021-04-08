# frozen_string_literal: true

module BulkImports
  module Groups
    module Graphql
      module GetGroupAvatarQuery
        extend self

        def to_s
          <<-'GRAPHQL'
          query($full_path: ID!) {
            group(fullPath: $full_path) {
              avatar_url: avatarUrl
            }
          }
          GRAPHQL
        end

        def variables(context)
          { full_path: context.entity.source_full_path }
        end

        def base_path
          %w[data group]
        end

        def data_path
          base_path
        end
      end
    end
  end
end
