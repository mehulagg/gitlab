# frozen_string_literal: true

module Types
  module Admin
    module CloudLicenses
      # rubocop: disable Graphql/AuthorizeTypes
      class LicenseHistoryEntryType < BaseObject
        include Gitlab::Graphql::Authorize::AuthorizeResource

        graphql_name 'LicenseHistoryEntry'
        description 'Represents an entry from the Cloud License history'

        field :name, GraphQL::STRING_TYPE, null: true,
              description: 'Name of the licensee.'

        field :email, GraphQL::STRING_TYPE, null: true,
              description: 'Email of the licensee.'

        field :company, GraphQL::STRING_TYPE, null: true,
              description: 'Company of the licensee.'

        field :plan, GraphQL::STRING_TYPE, null: true,
              description: 'Name of the subscription plan.'

        field :activated_on, ::Types::TimeType, null: true,
              description: 'Company of the licensee.'

        field :valid_from, ::Types::DateType, null: true,
              description: 'Date when the license started.'

        field :expires_on, ::Types::DateType, null: true,
              description: 'Date when the license expires on.'

        field :users_in_license, GraphQL::INT_TYPE, null: true,
              description: 'Number of users paid for in the license.'
      end
    end
  end
end
