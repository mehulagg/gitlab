# frozen_string_literal: true

module Gitlab
  module Database
    module Partitioning
      class PartitionManager
        include Gitlab::ExclusiveLeaseHelpers

        def self.register(model)
          raise ArgumentError, "Only models with a #partitioning_strategy can be registered." unless model.respond_to?(:partitioning_strategy)

          models << model
        end

        def self.models
          @models ||= Set.new
        end

        LEASE_TIMEOUT = 1.minute
        LEASE_KEY = 'database_partition_management_%s'

        attr_reader :models

        def initialize(models = self.class.models)
          @models = models
        end

        def create_partitions
          Gitlab::AppLogger.info("Checking state of dynamic postgres partitions")

          models.each do |model|
            # Double-checking before getting the lease:
            # The prevailing situation is no missing partitions
            next if missing_partitions(model).empty?

            only_with_lease_lock(model) do
              partitions_to_create = missing_partitions(model)

              next if partitions_to_create.empty?

              create(model, partitions_to_create)
            end
          rescue StandardError => e
            Gitlab::AppLogger.error("Failed to create partition(s) for #{model.table_name}: #{e.class}: #{e.message}")
          end
        end

        def detach_partitions
          return unless Feature.enabled?(:partition_pruning_dry_run)

          models.each do |model|
            next if extra_partitions(model).empty?

            only_with_lease_lock(model) do
              partitions_to_detach = extra_partitions(model)

              next if partitions_to_detach.empty?

              detach(partitions_to_detach)
            end
          rescue StandardError => e
            Gitlab::AppLogger.error("Failed to remove partition(s) for #{model.table_name}: #{e.class}: #{e.message}")
          end
        end

        private

        def missing_partitions(model)
          return [] unless connection.table_exists?(model.table_name)

          model.partitioning_strategy.missing_partitions
        end

        def extra_partitions(model)
          return [] unless connection.table_exists?(model.table_name)

          model.partitioning_strategy.extra_partitions
        end

        def only_with_lease_lock(model)
          in_lock(LEASE_KEY % model.table_name, ttl: LEASE_TIMEOUT, sleep_sec: 3.seconds) do
            yield
          end
        end

        def create(model, partitions)
          connection.transaction do
            with_lock_retries do
              partitions.each do |partition|
                connection.execute partition.to_sql

                Gitlab::AppLogger.info("Created partition #{partition.partition_name} for table #{partition.table}")
              end
            end
          end
        end

        def detach(partitions)
          connection.transaction do
            with_lock_retries do
              partitions.each { |p| detach_one_partition(p) }
            end
          end
        end

        def detach_one_partition(partition)
          Gitlab::AppLogger.info("Planning to detach #{partition.partition_name} for table #{partition.table}")
        end

        def with_lock_retries(&block)
          Gitlab::Database::WithLockRetries.new(
            klass: self.class,
            logger: Gitlab::AppLogger
          ).run(&block)
        end

        def connection
          ActiveRecord::Base.connection
        end
      end
    end
  end
end
