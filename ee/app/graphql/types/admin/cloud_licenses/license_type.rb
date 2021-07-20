# frozen_string_literal: true

module Types
  module Admin
    module CloudLicenses
      module LicenseType
        extend ActiveSupport::Concern

        included do
          field :id, GraphQL::ID_TYPE, null: false,
                description: 'ID of the license.',
                method: :license_id

          field :type, GraphQL::STRING_TYPE, null: false,
                description: 'Type of the license.',
                method: :license_type

          field :plan, GraphQL::STRING_TYPE, null: false,
                description: 'Name of the subscription plan.'

          field :name, GraphQL::STRING_TYPE, null: true,
                description: 'Name of the licensee.',
                method: :licensee_name

          field :email, GraphQL::STRING_TYPE, null: true,
                description: 'Email of the licensee.',
                method: :licensee_email

          field :company, GraphQL::STRING_TYPE, null: true,
                description: 'Company of the licensee.',
                method: :licensee_company

          field :starts_at, ::Types::DateType, null: true,
                description: 'Date when the license started.'

          field :expires_at, ::Types::DateType, null: true,
                description: 'Date when the license expires.'

          field :block_changes_at, ::Types::DateType, null: true,
                description: 'Date, including grace period, when licensed features will be blocked.'

          field :activated_at, ::Types::DateType, null: true,
                description: 'Date when the license was activated.'

          field :users_in_license_count, GraphQL::INT_TYPE, null: true,
                description: 'Number of paid users in the license.',
                method: :restricted_user_count
        end
      end
    end
  end
end
