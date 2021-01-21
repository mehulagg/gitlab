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
              method: :contains_locked_projects?

        field :repository_size_excess_project_count,
              GraphQL::INT_TYPE,
              null: false,
              description: 'Number of projects in the root namespace where the repository size exceeds the limit'

        field :actual_repository_size_limit,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Size limit for repositories in the namespace in bytes',
              method: :actual_size_limit

        field :storage_size_limit,
              GraphQL::FLOAT_TYPE,
              null: true,
              description: 'Total storage limit of the root namespace in bytes'

        field :is_temporary_storage_increase_enabled,
              GraphQL::BOOLEAN_TYPE,
              null: false,
              description: 'Status of the temporary storage increase',
              method: :temporary_storage_increase_enabled?

        field :temporary_storage_increase_ends_on,
              ::Types::TimeType,
              null: true,
              description: 'Date until the temporary storage increase is active'

        field :compliance_frameworks,
              ::Types::ComplianceManagement::ComplianceFrameworkType.connection_type,
              null: true,
              description: 'Compliance frameworks available to projects in this namespace.',
              feature_flag: :ff_custom_compliance_frameworks do
                argument :id, ::Types::GlobalIDType[::ComplianceManagement::Framework],
                         description: 'Global ID of a specific compliance framework to return.',
                         required: false
              end

        def additional_purchased_storage_size
          object.additional_purchased_storage_size.megabytes
        end

        def storage_size_limit
          object.root_storage_size.limit
        end

        def compliance_frameworks(id: nil)
          id = ::Types::GlobalIDType[::ComplianceManagement::Framework].coerce_isolated_input(id) unless id.nil?
          BatchLoader::GraphQL
            .for([object.id, id&.model_id])
            .batch(default_value: []) do |keys, loader|
            namespace_ids = keys.map(&:first).uniq
            by_namespace_id = keys.group_by(&:first).transform_values { |k| k.map(&:second) }
            frameworks = ::ComplianceManagement::Framework.with_namespaces(namespace_ids)
            frameworks.group_by(&:namespace_id).each do |ns_id, group|
              by_namespace_id[ns_id].each do |fw_id|
                group.each do |fw|
                  next unless fw_id.nil? || fw_id.to_i == fw.id

                  loader.call([ns_id, fw_id]) { |array| array << fw }
                end
              end
            end
          end
        end
      end
    end
  end
end
