# frozen_string_literal: true

class InitializeConversionOfCiBuildsToBigint < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  TABLE = :ci_builds
  COLUMNS = %i(id stage_id)
  TARGET_COLUMNS = COLUMNS.map { |col| "#{col}_convert_to_bigint" }

  def up
    initialize_conversion_of_integer_to_bigint(TABLE, COLUMNS)
  end

  def down
    trigger_name = rename_trigger_name(TABLE, COLUMNS, TARGET_COLUMNS)
    remove_rename_triggers_for_postgresql TABLE, trigger_name

    TARGET_COLUMNS.each do |column|
      remove_column TABLE, column
    end
  end
end
