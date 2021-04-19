# frozen_string_literal: true

module Gitlab
  module Database
    class IntegerToBigintMigration < ActiveRecord::Migration[6.0]
      include Gitlab::Database::MigrationHelpers

      IntegerToBigintConversion = Struct.new(:table, :columns) do
        def target_columns
          columns.map { |col| "#{col}_convert_to_bigint"}
        end
      end

      def up
        conversion.columns.each do |column|
          initialize_conversion_of_integer_to_bigint conversion.table, column
        end

        install_rename_triggers_for_conversion_of_integer_to_bigint conversion.table, conversion.columns
      end

      def down
        trigger_name = rename_trigger_name(conversion.table, conversion.columns, conversion.target_columns)
        remove_rename_triggers_for_postgresql conversion.table, trigger_name

        conversion.target_columns.each do |column|
          remove_column conversion.table, column
        end
      end
    end
  end
end
