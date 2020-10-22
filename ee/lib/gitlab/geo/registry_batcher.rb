# frozen_string_literal: true

module Gitlab
  module Geo
    # Returns an ID range to allow iteration over a registry table and its
    # source replicable table. Repeats from the beginning after it reaches
    # the end.
    #
    # Used by Geo in particular to iterate over a replicable and its registry
    # table.
    #
    # Tracks a cursor for each table, by "key". If the table is smaller than
    # batch_size, then a range for the whole table is returned on every call.
    class RegistryBatcher
      # @param [Class] registry_class the class of the table to iterate on
      # @param [String] key to identify the cursor. Note, cursor is already unique
      #   per table.
      # @param [Integer] batch_size to limit the number of records in a batch
      def initialize(registry_class, key:, batch_size: 1000)
        @model_class = registry_class::MODEL_CLASS
        @model_foreign_key = registry_class::MODEL_FOREIGN_KEY
        @registry_class = registry_class
        @key = key
        @batch_size = batch_size
      end

      # @return [Range] a range of IDs. `nil` if 0 records at or after the cursor.
      def next_range!
        batch_first_id = cursor_id
        batch_last_id  = get_batch_last_id(batch_first_id)
        return unless batch_last_id

        batch_first_id..batch_last_id
      end

      private

      attr_reader :model_class, :model_foreign_key, :registry_class, :key, :batch_size

      # @private
      #
      # Get the last ID of the batch. Increment the cursor or reset it if at end.
      #
      # @param [Integer] batch_first_id the first ID of the batch
      # @return [Integer] batch_last_id the last ID of the batch (not the table)
      def get_batch_last_id(batch_first_id)
        model_class_last_id, more_records = get_model_batch_last_id(batch_first_id)
        registry_class_last_id, more_registries = get_registry_batch_last_id(batch_first_id)

        batch_last_id =
          if !more_records && more_registries
            registry_class_last_id
          else
            model_class_last_id
          end

        if more_records || more_registries
          increment_batch(batch_last_id)
        else
          reset if batch_first_id > 1
        end

        batch_last_id
      end

      # @private
      #
      # Get the last ID of the of the batch (not the table) for the replicable
      # and check if there are more rows in the table.
      #
      # @param [Integer] batch_first_id the first ID of the batch
      # @return [Integer, Boolean] A tuple with the the last ID of the batch (not the table),
      #                            and whether or not have more rows to check in the table
      def get_model_batch_last_id(batch_first_id)
        sql = <<~SQL
          SELECT MAX(batch.#{model_class.primary_key}) AS batch_last_id,
          EXISTS (
            SELECT #{model_class.primary_key}
            FROM #{model_class.table_name}
            WHERE #{model_class.primary_key} > MAX(batch.#{model_class.primary_key})
          ) AS more_rows
          FROM (
            SELECT #{model_class.primary_key}
            FROM #{model_class.table_name}
            WHERE #{model_class.primary_key} >= #{batch_first_id}
            ORDER BY #{model_class.primary_key}
            LIMIT #{batch_size}) AS batch;
        SQL

        result = model_class.connection.exec_query(sql).first

        [result["batch_last_id"], result["more_rows"]]
      end

      # @private
      #
      # Get the last ID of the of the batch (not the table) for the registry
      # and check if there are more rows in the table.
      #
      # This query differs from the replicable query by:
      #
      # - We check against the foreign key IDs not the registry IDs;
      # - In the where clause of the more_rows part, we use greater
      #   than or equal. This allows the batcher to switch to the
      #   registry table while getting the last ID of the batch
      #   when the previous batch included the end of the replicable
      #   table but there are orphaned registries where the foreign key
      #   ids are higher than the last replicable id;
      #
      # @param [Integer] batch_first_id the first ID of the batch
      # @return [Integer, Boolean] A tuple with the the last ID of the batch (not the table),
      #                            and whether or not have more rows to check in the table
      def get_registry_batch_last_id(batch_first_id)
        sql = <<~SQL
          SELECT MAX(batch.#{model_foreign_key}) AS batch_last_id,
          EXISTS (
            SELECT #{model_foreign_key}
            FROM #{registry_class.table_name}
            WHERE #{model_foreign_key} >= MAX(batch.#{model_foreign_key})
          ) AS more_rows
          FROM (
            SELECT #{model_foreign_key}
            FROM #{registry_class.table_name}
            WHERE #{model_foreign_key} >= #{batch_first_id}
            ORDER BY #{model_foreign_key}
            LIMIT #{batch_size}) AS batch;
        SQL

        result = registry_class.connection.exec_query(sql).first

        [result["batch_last_id"], result["more_rows"]]
      end

      def reset
        set_cursor_id(1)
      end

      def increment_batch(batch_last_id)
        set_cursor_id(batch_last_id + 1)
      end

      # @private
      #
      # @return [Integer] the cursor ID, or 1 if it is not set
      def cursor_id
        Rails.cache.fetch("#{cache_key}:cursor_id") || 1
      end

      def set_cursor_id(id)
        Rails.cache.write("#{cache_key}:cursor_id", id)
      end

      def cache_key
        @cache_key ||= "#{self.class.name.parameterize}:#{registry_class.name.parameterize}:#{key}:cursor_id"
      end
    end
  end
end
