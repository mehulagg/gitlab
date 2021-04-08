# frozen_string_literal: true

module Types
  module Admin
    module CloudLicenses
      # rubocop: disable Graphql/AuthorizeTypes
      class LicenseHistoryEntryType < BaseObject
        include ::Types::Admin::CloudLicenses::LicenseType

        graphql_name 'LicenseHistoryEntry'
        description 'Represents an entry from the Cloud License history'

        field :activated_on, ::Types::DateType, null: true,
              description: 'Date when the license was activated.',
              method: :created_at
      end
    end
  end
end
