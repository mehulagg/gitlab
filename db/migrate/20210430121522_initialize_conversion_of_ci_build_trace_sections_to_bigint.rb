# frozen_string_literal: true

class InitializeConversionOfCiBuildTraceSectionsToBigint < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  TABLE = :ci_build_trace_sections
  COLUMN = :build_id
  TARGET_COLUMN = :build_id_convert_to_bigint

  def up
    initialize_conversion_of_integer_to_bigint(TABLE, COLUMN, primary_key: COLUMN)

    # Prepare new id column to act as a primary key later
    add_column(TABLE, :id, :bigint, default: 0, null: false)
    execute 'CREATE SEQUENCE ci_build_trace_sections_id_seq'
    change_column_default(TABLE, :id, "nextval('ci_build_trace_sections_id_seq'::regclass)")

    # TODO: Install UPDATE trigger to set `id = DEFAULT`
  end

  def down
    revert_initialize_conversion_of_integer_to_bigint(TABLE, COLUMN)

    remove_column(TABLE, :id)
    execute 'DROP SEQUENCE ci_build_trace_sections_id_seq'

    # TODO: DROP UPDATE trigger to set `id = DEFAULT`
  end
end
