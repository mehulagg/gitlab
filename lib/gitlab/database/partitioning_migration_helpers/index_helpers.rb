# frozen_string_literal: true

module Gitlab
  module Database
    module PartitioningMigrationHelpers
      module IndexHelpers
        include Gitlab::Database::MigrationHelpers
        include Gitlab::Database::SchemaHelpers

        def add_concurrent_partitioned_index(table_name, column_names, options = {})
          raise ArgumentError, 'A name is required for indexes added to partitioned tables' unless options[:name]

          return if index_name_exists?(table_name, options[:name])

          each_partition_for_table(table_name) do |partition_name|
            partition_index_name = generated_index_name(partition_name, options[:name])
            partition_options = options.merge(name: partition_index_name)

            add_concurrent_index(partition_name, column_names, partition_options)
          end

          add_index(table_name, column_names, options)
        end

        def remove_concurrent_partitioned_index_by_name(table_name, index_name)
          if find_model_for_table(table_name) && index_name_exists?(table_name, index_name)
            remove_index(table_name, name: index_name)
          end
        end

        private

        def each_partition_for_table(table_name, &block)
          model = find_model_for_table(table_name)

          model.current_partitions.map(&:qualified_partition_name).each(&block)
        end

        def find_model_for_table(table_name)
          models = Gitlab::Database::Partitioning::PartitionCreator.models
          model = models.find { |m| m.table_name == table_name.to_s }

          raise ArgumentError, "#{table_name} is not a registered partitioned table" unless model

          model
        end

        def generated_index_name(partition_name, index_name)
          object_name("#{partition_name}_#{index_name}", 'index')
        end
      end
    end
  end
end
