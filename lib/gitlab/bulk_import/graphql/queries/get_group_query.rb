# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Graphql
      module Queries
        GET_GROUP_QUERY = <<-'GRAPHQL'
          query($full_path: ID!) {
            group(fullPath: $full_path) {
              name
              path
              description
              visibility
              emailsDisabled
              lfsEnabled
              mentionsDisabled
              projectCreationLevel
              requestAccessEnabled
              requireTwoFactorAuthentication
              shareWithGroupLock
              subgroupCreationLevel
              twoFactorGracePeriod
            }
          }
        GRAPHQL
      end
    end
  end
end
