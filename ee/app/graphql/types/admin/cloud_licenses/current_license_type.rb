# frozen_string_literal: true

module Types
  module Admin
    module CloudLicenses
      # rubocop: disable Graphql/AuthorizeTypes
      class CurrentLicenseType < BaseObject
        include ::Types::Admin::CloudLicenses::LicenseType

        graphql_name 'CurrentLicense'
        description 'Represents the current Cloud License'

        field :id, GraphQL::ID_TYPE, null: false,
              description: 'ID of the license in the database.',
              method: :license_id

        field :last_sync, ::Types::DateType, null: true,
              description: 'Date when the license was last sync.'

        field :renews, ::Types::DateType, null: true,
              description: 'Date when the license renews.'

        field :address, GraphQL::STRING_TYPE, null: true,
              description: 'Address of the licensee.'

        field :users_in_license, GraphQL::INT_TYPE, null: true,
              description: 'Number of users paid for in the license.'

        field :billable_users, GraphQL::INT_TYPE, null: true,
              description: 'Number of billable users on your system.',
              method: :daily_billable_users_count

        field :maximum_users, GraphQL::INT_TYPE, null: true,
              description: 'Highest number of billable users on your system during the term of the current license.',
              method: :maximum_user_count

        field :users_over_subscription, GraphQL::INT_TYPE, null: true,
              description: 'Number of users over the paid users in license.'

        def last_sync
        end

        def address
          object.licensee['Address']
        end

        def users_over_subscription
          return 0 if object.trial?

          current_license_overage = object.overage_with_historical_max
          current_license_overage > 0 ? current_license_overage : 0
        end
      end
    end
  end
end
