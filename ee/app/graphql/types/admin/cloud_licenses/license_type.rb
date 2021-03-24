# frozen_string_literal: true

module Types
  module Admin
    module CloudLicenses
      # rubocop: disable Graphql/AuthorizeTypes
      class LicenseType < BaseObject
        graphql_name 'License'
        description 'Represents the current Cloud License'

        connection_type_class(::Types::Admin::CloudLicenses::LicenseType)

        field :id, GraphQL::ID_TYPE, null: true,
              description: 'ID of the license in the database.',
              method: :license_id

        field :plan, GraphQL::STRING_TYPE, null: true,
              description: 'Name of the subscription plan.'

        field :last_sync, ::Types::DateType, null: true,
              description: 'Date when the license was last sync.'

        field :starts_at, ::Types::DateType, null: true,
              description: 'Date when the license started.'

        field :renews, ::Types::DateType, null: true,
              description: 'Date when the license renews.'

        field :name, GraphQL::STRING_TYPE, null: true,
              description: 'Name of the licensee.'

        field :email, GraphQL::STRING_TYPE, null: true,
              description: 'Email of the licensee.'

        field :company, GraphQL::STRING_TYPE, null: true,
              description: 'Company of the licensee.'

        field :address, GraphQL::STRING_TYPE, null: true,
              description: 'Address of the licensee.'

        field :users_in_subscription, GraphQL::INT_TYPE, null: true,
              description: 'Number of users paid for in the license.'

        field :billable_users, GraphQL::INT_TYPE, null: true,
              description: 'Number of billable users on your system.',
              method: :daily_billable_users_count

        field :maximum_users, GraphQL::INT_TYPE, null: true,
              description: 'Highest number of billable users on your system during the term of the current license.',
              method: :maximum_user_count

        field :users_over_subscription, GraphQL::INT_TYPE, null: true,
              description: 'Number of users over the paid users in license.'

        def plan
          object.plan.capitalize
        end

        def name
          object.licensee['Name']
        end

        def email
          object.licensee['Email']
        end

        def company
          object.licensee['Company']
        end

        def address
          object.licensee['Address']
        end

        def users_in_subscription
          if object.restricted?(:active_user_count)
            object.restrictions[:active_user_count]
          else
            nil
          end
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
