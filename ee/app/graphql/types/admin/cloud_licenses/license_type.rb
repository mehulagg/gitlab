# frozen_string_literal: true

module Types
  module Admin
    module CloudLicenses
      module LicenseType
        extend ActiveSupport::Concern

        included do
          field :type, GraphQL::STRING_TYPE, null: false,
                description: 'Type of the subscription.'

          field :plan, GraphQL::STRING_TYPE, null: false,
                description: 'Name of the subscription plan.'

          field :name, GraphQL::STRING_TYPE, null: true,
                description: 'Name of the licensee.'

          field :email, GraphQL::STRING_TYPE, null: true,
                description: 'Email of the licensee.'

          field :company, GraphQL::STRING_TYPE, null: true,
                description: 'Company of the licensee.'

          field :starts_at, ::Types::DateType, null: true,
                description: 'Date when the license started.'

          field :expires_at, ::Types::DateType, null: true,
                description: 'Date when the license expires.'

          field :users_in_license, GraphQL::INT_TYPE, null: true,
                description: 'Number of users paid for in the license.'

          def type
            object.cloud? ? :cloud : :legacy
          end

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

          def users_in_license
            if object.restricted?(:active_user_count)
              object.restrictions[:active_user_count]
            else
              nil
            end
          end
        end
      end
    end
  end
end
