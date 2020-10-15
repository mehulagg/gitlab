# frozen_string_literal: true

module BulkImports
  module Groups
    module Graphql
      GET_GROUP_QUERY = <<-'GRAPHQL'
        query($full_path: ID!) {
          group(fullPath: $full_path) {
            name
            path
            fullPath
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
