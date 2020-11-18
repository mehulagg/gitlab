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
              description: 'Includes at least one project where the repository size exceeds the limit'

        field :repository_size_excess_project_count,
              GraphQL::INT_TYPE,
              null: false,
              description: 'Number of projects in the root namespace where the repository size exceeds the limit'

        field :actual_repository_size_limit,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Size limit for repositories in the namespace in bytes'

        field :storage_size_limit,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Total storage limit of the root namespace in bytes'

        field :is_temporary_storage_increase_enabled,
              GraphQL::BOOLEAN_TYPE,
              null: false,
              description: 'Status of the temporary storage increase'

        field :temporary_storage_increase_ends_on,
              ::Types::TimeType,
              null: true,
              description: 'Date until the temporary storage increase is active'

        def additional_purchased_storage_size
          object.additional_purchased_storage_size.megabytes
        end

        def contains_locked_projects
          object.contains_locked_projects?
        end

        def actual_repository_size_limit
          object.actual_size_limit
        end

        def storage_size_limit
          object.root_storage_size.limit
        end

        # rubocop:disable Naming/PredicateName
        def is_temporary_storage_increase_enabled
          object.temporary_storage_increase_enabled?
        end
        # rubocop:enable Naming/PredicateName
      end
    end
  end
end
