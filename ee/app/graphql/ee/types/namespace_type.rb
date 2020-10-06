# frozen_string_literal: true

module EE
  module Types
    module NamespaceType
      extend ActiveSupport::Concern

      prepended do
        field :additional_purchased_storage_size,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Additional storage purchased for the root namespace in bytes'

        field :total_repository_size_excess,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Total excess repository size of all projects in the root namespace in bytes'

        field :total_repository_size,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Total repository size of all projects in the root namespace in bytes'

        field :contains_locked_projects,
              GraphQL::BOOLEAN_TYPE,
              null: false,
              description: 'Includes at least one project where the repository size exceeds the limit',
              resolve: -> (obj, _args, _ctx) { obj.contains_locked_projects? }

        field :repository_size_excess_project_count,
              GraphQL::INT_TYPE,
              null: false,
              description: 'Number of projects in the root namespace where the repository size exceeds the limit'

        field :storage_size_limit,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Total storage limit of the root namespace in bytes',
              resolve: -> (obj, _args, _ctx) { EE::Namespace::RootStorageSize.new(obj).limit }

        field :is_temporary_storage_increase_enabled,
              GraphQL::BOOLEAN_TYPE,
              null: false,
              description: 'Status of the temporary storage increase',
              resolve: -> (obj, _args, _ctx) { obj.temporary_storage_increase_enabled? }

        field :temporary_storage_increase_ends_on,
              ::Types::TimeType,
              null: true,
              description: 'Date until the temporary storage increase is active'
      end
    end
  end
end
