# frozen_string_literal: true

module Types
  module Admin
    module CloudLicenses
      # rubocop: disable Graphql/AuthorizeTypes
      class LicenseHistoryEntryType < BaseObject
        include ::Types::Admin::CloudLicenses::LicenseType

        graphql_name 'LicenseHistoryEntry'
        description 'Represents an entry from the Cloud License history'
      end
    end
  end
end
