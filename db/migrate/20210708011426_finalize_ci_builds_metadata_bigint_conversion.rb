# frozen_string_literal: true

class FinalizeCiBuildsMetadataBigintConversion < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  disable_ddl_transaction!

  TABLE_NAME = 'ci_builds_metadata'

  def up
    ensure_batched_background_migration_is_finished(
      job_class_name: 'CopyColumnUsingBackgroundMigrationJob',
      table_name: TABLE_NAME,
      column_name: 'id',
      job_arguments: [["id"], ["id_convert_to_bigint"]]
    )

    swap
  end

  def down
    swap
  end

  private

  def swap
    # This is to replace the existing "ci_builds_metadata_pkey" PRIMARY KEY, btree (id)
    # TODO: Add index to gitlab.com beforehand to avoid slowing down the deployment
    add_concurrent_index TABLE_NAME, :id_convert_to_bigint, unique: true, name: 'index_ci_builds_metadata_on_id_convert_to_bigint'

    with_lock_retries(raise_on_exhaustion: true) do
      execute "LOCK TABLE #{TABLE_NAME} IN ACCESS EXCLUSIVE MODE" # TODO: Any FKs referencing this table?

      # Swap column names
      temp_name = 'id_tmp'
      execute "ALTER TABLE #{quote_table_name(TABLE_NAME)} RENAME COLUMN #{quote_column_name(:id)} TO #{quote_column_name(temp_name)}"
      execute "ALTER TABLE #{quote_table_name(TABLE_NAME)} RENAME COLUMN #{quote_column_name(:id_convert_to_bigint)} TO #{quote_column_name(:id)}"
      execute "ALTER TABLE #{quote_table_name(TABLE_NAME)} RENAME COLUMN #{quote_column_name(temp_name)} TO #{quote_column_name(:id_convert_to_bigint)}"

      # We need to update the trigger function in order to make PostgreSQL to
      # regenerate the execution plan for it. This is to avoid type mismatch errors like
      # "type of parameter 15 (bigint) does not match that when preparing the plan (integer)"
      function_name = Gitlab::Database::UnidirectionalCopyTrigger.on_table(TABLE_NAME).name(:id, :id_convert_to_bigint)
      execute "ALTER FUNCTION #{quote_table_name(function_name)} RESET ALL"
    end
  end
end
